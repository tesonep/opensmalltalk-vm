/**
 * Author: Ronie Salgado <roniesalg@gmail.com>
 * License: MIT
 */
#include <stdio.h>
#include <stdlib.h>

/* Do not include the entire sq.h file but just those parts needed. */
/*  The virtual machine proxy definition */
#include "sqVirtualMachine.h"
#include "sqAssert.h"
/* Configuration options */
#include "sqConfig.h"
/* Platform specific definitions */
#include "sqPlatformSpecific.h"
#include "B3DAcceleratorPlugin.h"

#ifdef B3DX_METAL
#import "sqMetalRenderer.h"
#import "B3DMetalShaders.metal.inc"

extern id<MTLDevice> getMainWindowMetalDevice(void);
extern id<MTLCommandQueue> getMainWindowMetalCommandQueue(void);

extern unsigned int createMetalTextureLayerHandle(void);
extern void destroyMetalTextureLayerHandle(unsigned int handle);
extern void setMetalTextureLayerContent(unsigned int handle, id<MTLTexture> texture, int x, int y, int w, int h);

#define UNIMPLEMENTED() printf("Unimplemented: %s\n", __func__)

static sqB3DMetalModule *b3dMetalModuleSingleton = nil;

@implementation sqB3DMetalModule
@synthesize device, shaderLibrary;

+ (sqB3DMetalRenderer*)getRendererFromHandle: (int)handle {
    if(b3dMetalModuleSingleton)
        return [b3dMetalModuleSingleton getRendererFromHandle: handle];
    return nil;
}

- (sqB3DMetalRenderer*)getRendererFromHandle: (int)handle {
    if(handle < 0 || handle >= MAX_NUMBER_OF_RENDERERS)
        return nil;
    return renderers[handle];
}

- (int) createRendererX: (int)x y: (int)y w: (int)w h: (int)h flags: (int)flags {
    int rendererHandler;
    for(rendererHandler = 0; rendererHandler < MAX_NUMBER_OF_RENDERERS; ++rendererHandler) {
        if(!renderers[rendererHandler])
            break;
    }
    
    if(rendererHandler >= MAX_NUMBER_OF_RENDERERS)
        return -1;
    
    // Create the renderer
    sqB3DMetalRenderer *renderer = [sqB3DMetalRenderer new];
    renderer.device = device;
    if(![renderer setupSurfaceX: x y: y w: w h: h flags: flags]) {
        RELEASEOBJ(renderer);
        return -1;
    }
    
    renderers[rendererHandler] = renderer;
    printf("Created renderer %d\n", rendererHandler);
    return rendererHandler;
}

- (int) destroyRendererWithHandle: (int)handle {
    if(handle < 0 || handle >= MAX_NUMBER_OF_RENDERERS || !renderers[handle])
        return 0;
        
    [renderers[handle] destroy];
    
    RELEASEOBJ(renderers[handle]);
    renderers[handle] = nil;
    printf("Destroyed renderer %d\n", handle);
    return 1;
}
@end

/* module initialization support */
/* return true on success, false on error */
int b3dMetalInitialize(void) {
    if(b3dMetalModuleSingleton)
        return 1;

    id<MTLDevice> device = getMainWindowMetalDevice();
    if(!device) {
        device = MTLCreateSystemDefaultDevice();
        if(!device)
            return 0;
    }
    
    NSError *libraryError;
    dispatch_data_t metalLibraryData = dispatch_data_create(B3DMetalShaders_metallib, B3DMetalShaders_metallib_len, dispatch_get_global_queue(0, 0), ^{});
    id<MTLLibrary> shaderLibrary = [device newLibraryWithData: metalLibraryData error: &libraryError];
#if !__has_feature(objc_arc)
    dispatch_release(metalLibraryData);
#endif
    if(!shaderLibrary)
    {
        NSLog(@"Shader library error: %@", libraryError.localizedDescription);
        return 0;
    }

    b3dMetalModuleSingleton = [sqB3DMetalModule new];
    b3dMetalModuleSingleton.device = device;
    b3dMetalModuleSingleton.shaderLibrary = shaderLibrary;
    return 1;
}

/* return true on success, false on error */
int b3dMetalShutdown(void) {
    if(b3dMetalModuleSingleton)
    {
        RELEASEOBJ(b3dMetalModuleSingleton);
        b3dMetalModuleSingleton = nil;
    }

    return 1;
}

@implementation sqB3DMetalRenderBuffer

@synthesize width, height, flags, colorBuffer, depthStencilBuffer;

+ (sqB3DMetalRenderBuffer*) createFor: (id<MTLDevice>)device width: (int)width height: (int) height flags: (int)flags {
    id<MTLTexture> colorBuffer;
    id<MTLTexture> depthStencilBuffer;
    
    // Create the color buffer
    {
        MTLTextureDescriptor *colorBufferDescriptor = [MTLTextureDescriptor
            texture2DDescriptorWithPixelFormat: MTLPixelFormatRGBA8Unorm
            width: width height: height mipmapped: NO];

        colorBuffer = [device newTextureWithDescriptor: colorBufferDescriptor];
        RELEASEOBJ(colorBufferDescriptor);
        if(!colorBuffer)
            return nil;        
    }

    // Create the depth stencil buffer
    {
        MTLPixelFormat depthStencilFormat = MTLPixelFormatDepth32Float;
        if(flags & B3D_STENCIL_BUFFER)
            depthStencilFormat = MTLPixelFormatDepth32Float_Stencil8;
        
        MTLTextureDescriptor *depthStencilBufferDescriptor = [MTLTextureDescriptor
            texture2DDescriptorWithPixelFormat: depthStencilFormat
            width: width height: height mipmapped: NO];
        depthStencilBufferDescriptor.storageMode = MTLStorageModePrivate;

        depthStencilBuffer = [device newTextureWithDescriptor: depthStencilBufferDescriptor];
        RELEASEOBJ(depthStencilBufferDescriptor);
        if(!depthStencilBuffer)
            return nil;        
    }

    sqB3DMetalRenderBuffer *result = [sqB3DMetalRenderBuffer new];
    result.width = width;
    result.height = height;
    result.flags = flags;
    result.colorBuffer = colorBuffer;
    result.depthStencilBuffer = depthStencilBuffer;
    return result;
}

- (MTLRenderPassDescriptor*) createRenderPassDescriptor {
    MTLRenderPassDescriptor *descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    descriptor.colorAttachments[0].texture = colorBuffer;
    descriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
    descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;

    descriptor.depthAttachment.texture = depthStencilBuffer;
    descriptor.depthAttachment.loadAction = MTLLoadActionLoad;
    descriptor.depthAttachment.storeAction = MTLStoreActionStore;
    
    if(flags & B3D_STENCIL_BUFFER) {
        descriptor.stencilAttachment.texture = depthStencilBuffer;
        descriptor.stencilAttachment.loadAction = MTLLoadActionLoad;
        descriptor.stencilAttachment.storeAction = MTLStoreActionStore;
    }
    
    return descriptor;
}

- (void) setupPipelineDescriptor: (MTLRenderPipelineDescriptor*) pipelineDescriptor {
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatRGBA8Unorm;
    if(flags & B3D_STENCIL_BUFFER) {
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
        pipelineDescriptor.stencilAttachmentPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    } else {
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    }
}

@end

@implementation sqB3DMetalRenderer

@synthesize device, surfaceX, surfaceY, surfaceWidth, surfaceHeight;

- (BOOL) setupSurfaceX: (int)x y: (int)y w: (int)w h: (int)h flags: (int)flags {
    // Store the surface dimensions.
    surfaceX = x; surfaceY = y;
    surfaceWidth = w; surfaceHeight = h;
    
    // Create the texture layer handle.
    windowSurfaceLayerHandle = createMetalTextureLayerHandle();
    if(windowSurfaceLayerHandle == 0)
        return NO;
        
    // Create the render buffers.
    renderBuffers[0] = [sqB3DMetalRenderBuffer createFor: device width: w height: h flags: flags];
    renderBuffers[1] = [sqB3DMetalRenderBuffer createFor: device width: w height: h flags: flags];
    currentRenderBufferIndex = 0;
    if(!renderBuffers[0] || !renderBuffers[1])
    {
        destroyMetalTextureLayerHandle(windowSurfaceLayerHandle);
        return NO;
    }
    
    // Set the full framebuffer as the default viewport.
    viewport = (MTLViewport){0, 0, w, h, 0.0, 1.0};
    
    if(device == getMainWindowMetalDevice())
        commandQueue = getMainWindowMetalCommandQueue();
    if(!commandQueue)
        commandQueue = [device newCommandQueue];
        
    transformationState.modelViewMatrix = matrix_identity_float4x4;
    transformationState.projectionMatrix = matrix_identity_float4x4;
    
    [self createPipelines];
    
    return YES;
}

- (void) createPipelines {
    solidColorPipeline = [self buildPipelineWithVertexFunction: @"solidVertexShader" fragmentFunction: @"solidFragmentShader"];
}

- (void) destroy {
    destroyMetalTextureLayerHandle(windowSurfaceLayerHandle);
}

- (MTLVertexDescriptor*) createVertxDescriptor {
    MTLVertexDescriptor* descriptor = [MTLVertexDescriptor vertexDescriptor];
    
    descriptor.attributes[0].format = MTLVertexFormatFloat4;
    descriptor.attributes[0].offset = offsetof(B3DPrimitiveVertex, position);
    descriptor.attributes[0].bufferIndex = 3;

    descriptor.attributes[1].format = MTLVertexFormatUChar4Normalized;
    descriptor.attributes[1].offset = offsetof(B3DPrimitiveVertex, pixelValue32);
    descriptor.attributes[1].bufferIndex = 3;

    descriptor.attributes[2].format = MTLVertexFormatFloat3;
    descriptor.attributes[2].offset = offsetof(B3DPrimitiveVertex, normal);
    descriptor.attributes[2].bufferIndex = 3;

    descriptor.attributes[3].format = MTLVertexFormatFloat2;
    descriptor.attributes[3].offset = offsetof(B3DPrimitiveVertex, texCoord);
    descriptor.attributes[3].bufferIndex = 3;
    
    descriptor.layouts[3].stride = sizeof(B3DPrimitiveVertex);
    return descriptor;
}
- (id<MTLRenderPipelineState>) buildPipelineWithVertexFunction: (NSString*)vertexFunctionName fragmentFunction: (NSString*)fragmentFunctionName {
    id<MTLLibrary> shaderLibrary = b3dMetalModuleSingleton.shaderLibrary;
    
	// Retrieve the shaders from the shader libary.
	id<MTLFunction> vertexShader = [shaderLibrary newFunctionWithName: vertexFunctionName];
	id<MTLFunction> fragmentShader = [shaderLibrary newFunctionWithName: fragmentFunctionName];
	if(!vertexShader || !fragmentShader)
	{
		RELEASEOBJ(shaderLibrary);
		return nil;
	}

	// Create the screen quad pipeline.
	MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
	pipelineDescriptor.vertexFunction = vertexShader;
	pipelineDescriptor.fragmentFunction = fragmentShader;
    pipelineDescriptor.vertexDescriptor = [self createVertxDescriptor];
    [renderBuffers[0] setupPipelineDescriptor: pipelineDescriptor];
	
	NSError *pipelineError = NULL;
	id<MTLRenderPipelineState> pipeline = [self.device newRenderPipelineStateWithDescriptor: pipelineDescriptor error: &pipelineError];
	RELEASEOBJ(shaderLibrary);
	RELEASEOBJ(vertexShader);
	RELEASEOBJ(fragmentShader);
	if(!pipeline)
	{
		NSLog(@"Pipeline state creation error: %@", pipelineError.localizedDescription);
		return nil;
	}
	
	return pipeline;
}

- (BOOL) viewportX: (int)x y: (int)y width: (int)width height: (int)height {
    viewport = (MTLViewport){x, y, width, height, 0.0, 1.0};
    if(activeRenderEncoder) {
        [activeRenderEncoder setViewport: viewport];
    }
    return YES;
}

- (BOOL) clearDepthBuffer {
    if(activeRenderEncoder)
        [self flushRenderPass];
        
    shouldClearDepthStencil = YES;
    return YES;
}

- (BOOL) clearViewportWithRGBA: (unsigned int) rgba {
    if(activeRenderEncoder)
        [self flushRenderPass];

    shouldClearColorBuffer = YES;
    currentClearColor.red   = ((rgba >> 16) & 255) / 255.0f;
    currentClearColor.green = ((rgba >>  8) & 255) / 255.0f;
    currentClearColor.blue  = (rgba & 255) / 255.0f;
    currentClearColor.alpha = (rgba >> 24) / 255.0f;
    return YES;
}

- (BOOL) setModelView: (float*) newModelView projection: (float*)newProjection {
    if(newModelView) {
        memcpy(&transformationState.modelViewMatrix, newModelView, 4*4*4);
        transformationState.modelViewMatrix = matrix_transpose(transformationState.modelViewMatrix);
    } else {
        transformationState.modelViewMatrix = matrix_identity_float4x4;
    }
    
    if(newProjection) {        
        memcpy(&transformationState.projectionMatrix, newProjection, 4*4*4);
        transformationState.projectionMatrix = matrix_transpose(transformationState.projectionMatrix);
    } else {
        transformationState.projectionMatrix = matrix_identity_float4x4;
    }
    
    transformationState.projectionMatrix = matrix_multiply(
        matrix_from_rows(
            vector4(1.0f, 0.0f, 0.0f, 0.0f),
            vector4(0.0f, -1.0f, 0.0f, 0.0f),
            vector4(0.0f, 0.0f, 0.5f, 0.5f),
            vector4(0.0f, 0.0f, 0.0f, 1.0f)),
            transformationState.projectionMatrix);
    hasValidTransformationState = NO;
    return YES;
}

- (BOOL) disableLights {
    lightingState.enabledLightMask = 0;
    hasValidLightingState = NO;
    return YES;
}

- (BOOL) loadMaterial: (B3DPrimitiveMaterial*) material {
    if(!material) {
        materialState.lightingEnabled = 0;
    } else {
        materialState.lightingEnabled = 1;
        memcpy(&materialState.material, material, sizeof(B3DMetalPrimitiveMaterial));
    }
    
    hasValidMaterialState = NO;
    return YES;
}

- (BOOL) loadLight: (B3DPrimitiveLight*) light index: (int)index {
    if(index < 0 || index >= MAX_NUMBER_OF_LIGHTS)
        return NO;
        
    if(light) {
        // Enable the light and copy its data.
        lightingState.enabledLightMask |= (1<<index);
        memcpy(&lightingState.lights[index], light, sizeof(B3DMetalPrimitiveLight));       
    } else {
        // Disable the light
        lightingState.enabledLightMask &= ~(1<<index);
    }
    
    hasValidLightingState = NO;
    return YES;
}

- (void) validateLightingState {
    if(hasValidLightingState)
        return;
        
    [activeRenderEncoder setVertexBytes: &lightingState length: sizeof(lightingState) atIndex: 0];
    hasValidLightingState = YES;
}

- (void) validateMaterialState {
    if(hasValidMaterialState)
        return;
        
    [activeRenderEncoder setVertexBytes: &materialState length: sizeof(materialState) atIndex: 1];
    hasValidMaterialState = YES;
}

- (void) validateTransformationState {
    if(hasValidTransformationState)
        return;
        
    [activeRenderEncoder setVertexBytes: &transformationState length: sizeof(transformationState) atIndex: 2];
    hasValidTransformationState = YES;
}

- (void) validateRenderState {
    [self validateLightingState];
    [self validateMaterialState];
    [self validateTransformationState];
}

- (void) setupPointRenderingFlags: (int)flags texHandle: (int) textureHandle {
    [activeRenderEncoder setRenderPipelineState: solidColorPipeline];
    [self validateRenderState];
}

- (void) setupLineRenderingFlags: (int)flags texHandle: (int) textureHandle {
    [activeRenderEncoder setRenderPipelineState: solidColorPipeline];
    [self validateRenderState];
}

- (void) setupTriangleRenderingFlags: (int)flags texHandle: (int) textureHandle {
    [activeRenderEncoder setRenderPipelineState: solidColorPipeline];
    [self validateRenderState];
}

- (BOOL) renderPrimitive: (int)primType flags: (int)flags texHandle: (int)textureHandle
    vertexArray: (float*)vertexArray vertexCount: (int) vertexCount
    indexArray: (int*)indexArray indexCount: (int)indexCount {

    // We need to be in a render pass.
    [self ensureRenderPass];
    
    // Upload the vertices
    size_t vertexBufferSize = vertexCount*sizeof(B3DPrimitiveVertex);
    [activeRenderEncoder setVertexBytes: vertexArray length: vertexBufferSize atIndex: 3];
        
    switch(primType) {
    case B3D_PRIMITIVE_TYPE_POINTS:
        [self setupPointRenderingFlags: flags texHandle: textureHandle];
        [activeRenderEncoder drawPrimitives: MTLPrimitiveTypePoint vertexStart: 0 vertexCount: vertexCount];
        break;
    case B3D_PRIMITIVE_TYPE_LINES:
        [self setupLineRenderingFlags: flags texHandle: textureHandle];
        [activeRenderEncoder drawPrimitives: MTLPrimitiveTypeLine vertexStart: 0 vertexCount: vertexCount];
        break;
    case B3D_PRIMITIVE_TYPE_INDEXED_LINES:
        [self setupLineRenderingFlags: flags texHandle: textureHandle];
        {
            id<MTLBuffer> indexBuffer = [device newBufferWithBytes: indexArray length: indexCount*4 options: MTLResourceStorageModePrivate];
            [activeRenderEncoder drawIndexedPrimitives: MTLPrimitiveTypeLine indexCount: indexCount indexType: MTLIndexTypeUInt32 indexBuffer: indexBuffer indexBufferOffset: 0];
            RELEASEOBJ(indexBuffer);
        }
        break;
    case B3D_PRIMITIVE_TYPE_INDEXED_TRIANGLES:
        [self setupTriangleRenderingFlags: flags texHandle: textureHandle];
        {
            id<MTLBuffer> indexBuffer = [device newBufferWithBytes: indexArray length: indexCount*4 options: MTLResourceStorageModePrivate];
            [activeRenderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: indexCount indexType: MTLIndexTypeUInt32 indexBuffer: indexBuffer indexBufferOffset: 0];
            RELEASEOBJ(indexBuffer);
        }
        break;

    // These other primitives require emulation
    case B3D_PRIMITIVE_TYPE_POLYGON:
        [self setupTriangleRenderingFlags: flags texHandle: textureHandle];
        {
            if(vertexCount < 3)
                return YES;
            
            // Allocate a temporary index buffer.    
            unsigned int triangleCount = vertexCount - 2;
            unsigned int renderIndexCount = triangleCount*3;    
            id<MTLBuffer> indexBuffer = [device newBufferWithLength: renderIndexCount*4 options: MTLResourceStorageModeManaged];
            
            // Set the triangle fan indices.
            unsigned int *destIndices = (unsigned int *)indexBuffer.contents;
            for(unsigned int i = 2; i < vertexCount; ++i) {
                destIndices[0] = 0;
                destIndices[1] = i - 1;
                destIndices[2] = i;
                destIndices += 3;
            }
            
            [activeRenderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: renderIndexCount indexType: MTLIndexTypeUInt32 indexBuffer: indexBuffer indexBufferOffset: 0];
            RELEASEOBJ(indexBuffer);
        }        
        break;
    case B3D_PRIMITIVE_TYPE_INDEXED_QUADS:
        [self setupTriangleRenderingFlags: flags texHandle: textureHandle];
        {
            unsigned int quadCount = indexCount/4;
            if(vertexCount == 0)
                return YES;
            
            // Allocate a temporary index buffer.  
            unsigned int triangleCount = quadCount*2;
            unsigned int renderIndexCount = triangleCount*3;    
            id<MTLBuffer> indexBuffer = [device newBufferWithLength: renderIndexCount*4 options: MTLResourceStorageModeManaged];
            
            // Expand the quad indices.
            unsigned int *sourceIndices = (unsigned int *)indexArray;
            unsigned int *destIndices = (unsigned int *)indexBuffer.contents;
            for(unsigned int i = 0; i < quadCount; ++i) {
                destIndices[0] = sourceIndices[0];
                destIndices[1] = sourceIndices[1];
                destIndices[2] = sourceIndices[2];

                destIndices[0] = sourceIndices[1];
                destIndices[1] = sourceIndices[2];
                destIndices[2] = sourceIndices[3];

                destIndices += 6;
            }
            
            [activeRenderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: renderIndexCount indexType: MTLIndexTypeUInt32 indexBuffer: indexBuffer indexBufferOffset: 0];
            RELEASEOBJ(indexBuffer);
        }
        break;
        
    default:
        // Ignored.
        break;
    }

    return YES;        
}

- (BOOL) hasPendingRenderPassCommands {
    return shouldClearDepthStencil || shouldClearDepthStencil;
}

- (void) ensureCommandBuffer {
    if(activeCommandBuffer)
        return;
        
    activeCommandBuffer = [commandQueue commandBuffer];
}

- (void) ensureRenderPass {
    if(activeRenderEncoder)
        return;
    
    [self ensureCommandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = [renderBuffers[currentRenderBufferIndex] createRenderPassDescriptor];
    
    // Do we need to clear the depth stencil buffer?
    if(shouldClearDepthStencil) {
        renderPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
        if(surfaceFlags & B3D_STENCIL_BUFFER) {
            renderPassDescriptor.stencilAttachment.loadAction = MTLLoadActionClear;            
        }
    }

    // Do we need to clear the color buffer?
    if(shouldClearColorBuffer) {
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPassDescriptor.colorAttachments[0].clearColor = currentClearColor;
    }
    
    activeRenderEncoder = [activeCommandBuffer renderCommandEncoderWithDescriptor: renderPassDescriptor];
    
    // There is no need to clear these buffers anymore.
    shouldClearDepthStencil = NO;
    shouldClearColorBuffer = NO;
    
    // Invalidate all of the render states.
    hasValidTransformationState = NO;
    hasValidMaterialState = NO;
    hasValidLightingState = NO;
}

- (void) flushRenderPass {
    if(!activeCommandBuffer && [self hasPendingRenderPassCommands]) {
        [self ensureRenderPass];        
    }

    if(activeRenderEncoder) {
        [activeRenderEncoder endEncoding];
        RELEASEOBJ(activeCommandBuffer);
        activeRenderEncoder = nil;
    }
}
- (BOOL) flush {
    if(!activeCommandBuffer && [self hasPendingRenderPassCommands]) {
        [self ensureRenderPass];        
    }
        
    if(activeCommandBuffer)
    {
        [self flushRenderPass];
        
        [activeCommandBuffer commit];
        RELEASEOBJ(activeCommandBuffer);
        activeCommandBuffer = nil;
    }
    return YES;
}

- (BOOL) finish {
    [self flush];

    // Commit an empty command buffer, and wait for it.
    id<MTLCommandBuffer> waitBuffer = [commandQueue commandBuffer];
    [waitBuffer commit];
    [waitBuffer waitUntilCompleted];
    return YES;
}

- (BOOL) swapBuffers {
    [self flush];
    
    setMetalTextureLayerContent(windowSurfaceLayerHandle, renderBuffers[currentRenderBufferIndex].colorBuffer, surfaceX, surfaceY, surfaceWidth, surfaceHeight);
    currentRenderBufferIndex = (currentRenderBufferIndex + 1) % 2;
    return YES;
}
@end
/* Texture support primitives */

/* return handle or -1 on error */
int
b3dMetalAllocateTexture(int renderer, int w, int h, int d) {
    UNIMPLEMENTED();
    return 0;
}

/* return true on success, false on error */
int
b3dMetalDestroyTexture(int renderer, int handle) {
    UNIMPLEMENTED();
    return 0;
}

/* return depth or <0 on error */
int
b3dMetalActualTextureDepth(int renderer, int handle) {
    UNIMPLEMENTED();
    return 0;
}

/* return true on success, false on error */
int
b3dMetalTextureColorMasks(int renderer, int handle, int masks[4]) {
    UNIMPLEMENTED();
    return 1;
}

/* return true on success, false on error */
int
b3dMetalUploadTexture(int renderer, int handle, int w, int h, int d, void* bits) {
    UNIMPLEMENTED();
    return 1;
}

/* return > 0 for MSB, = 0 for LSB, < 0 for error */
int
b3dMetalTextureByteSex(int renderer, int handle) {
    UNIMPLEMENTED();
    //struct glRenderer *renderer = glRendererFromHandle(rendererHandle);
	//if(!renderer) return -1;
#ifdef LSB_FIRST
	return 0;
#else
	return 1;
#endif    
} 

/* return handle or <0 if error */
int
b3dMetalTextureSurfaceHandle(int renderer, int handle) {
    return -1;
}

/* return true on success; else false */
int
b3dMetalCompositeTexture(int renderer, int handle, int x, int y, int w, int h, int translucent) {
    UNIMPLEMENTED();
    return 0;
}

/* Renderer primitives */
/* return handle or -1 on error */
int
b3dMetalCreateRendererFlags(int x, int y, int w, int h, int flags) {
    if(!b3dMetalModuleSingleton)
        return -1;

    return [b3dMetalModuleSingleton createRendererX: x y: y w: w h: h flags: flags];
}

/* return true on success, else false */
int
b3dMetalDestroyRenderer(int handle) {
    if(b3dMetalModuleSingleton)
        return [b3dMetalModuleSingleton destroyRendererWithHandle: handle];

    return 0;
}

 /* return true/false */
int
b3dMetalIsOverlayRenderer(int handle) {
    return 0;
}

 /* return true on success, false on error */
int
b3dMetalSetBufferRect(int handle, int x, int y, int w, int h) {
    UNIMPLEMENTED();
    return 0;
}

/* return handle or <0 if error */
int
b3dMetalGetRendererSurfaceHandle(int handle) {
    return -1;
}

/* return width or <0 if error */
int
b3dMetalGetRendererSurfaceWidth(int handle) {
    return -1;
}

/* return height or <0 if error */
int
b3dMetalGetRendererSurfaceHeight(int handle) {
    return -1;
}

/* return depth or <0 if error */
int
b3dMetalGetRendererSurfaceDepth(int handle) {
    return -1;
}

/* return true on success, false on error */
int
b3dMetalGetRendererColorMasks(int handle, int *masks)  {
    UNIMPLEMENTED();
    return 0;
}

/* return true on success, false on error */
int
b3dMetalSetViewport(int handle, int x, int y, int w, int h) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;

    return [renderer viewportX: x y: y width: w height: h];
}

/* return true on success, false on error */
int
b3dMetalClearDepthBuffer(int handle) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;
        
    return [renderer clearDepthBuffer];
}

/* return true on success, else false */
int
b3dMetalClearViewport(int handle, unsigned int rgba, unsigned int pv) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;
        
    return [renderer clearViewportWithRGBA: rgba];
}

int
b3dMetalSetTransform(int handle, float *modelView, float *projection) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;
        
    return [renderer setModelView: modelView projection: projection];
}

int
b3dMetalDisableLights(int handle) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;
        
    return [renderer disableLights];
}

int
b3dMetalLoadLight(int handle, int index, B3DPrimitiveLight *light) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;
        
    return [renderer loadLight: light index: index];
}

int
b3dMetalLoadMaterial(int handle, B3DPrimitiveMaterial *material) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;
        
    return [renderer loadMaterial: material];
}

/* return true on success, false on error */
int
b3dMetalRenderVertexBuffer(int handle, int primType, int flags, int texHandle, float *vtxArray, int vtxSize, int *idxArray, int idxSize) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;
        
    return [renderer renderPrimitive: primType flags: flags texHandle: texHandle
        vertexArray: vtxArray vertexCount: vtxSize
        indexArray: idxArray indexCount: idxSize
    ];
}

int
b3dMetalFlushRenderer(int handle) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;

    return [renderer flush];
}

int
b3dMetalFinishRenderer(int handle) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;

    return [renderer finish];
}

int
b3dMetalSwapRendererBuffers(int handle) {
    sqB3DMetalRenderer* renderer = [sqB3DMetalModule getRendererFromHandle: handle];
    if(!renderer)
        return 0;

    return [renderer swapBuffers];
}

int
b3dMetalGetIntProperty(int handle, int prop) {
    UNIMPLEMENTED();
    return 0;
}

int
b3dMetalSetIntProperty(int handle, int prop, int value) {
    UNIMPLEMENTED();
    return 0;
}

int
b3dMetalGetIntPropertyOS(int handle, int prop) {
    UNIMPLEMENTED();
    return 0;
}

int
b3dMetalSetIntPropertyOS(int handle, int prop, int value) {
    UNIMPLEMENTED();
    return 0;
}

int
b3dMetalSetVerboseLevel(int level) {
    UNIMPLEMENTED();
    return 0;
}

int
b3dMetalSetFog(int handle, int fogType, double density, double rangeStart, double rangeEnd, int rgba) {
    UNIMPLEMENTED();
    return 0;
}

/* Qwaq primitives */
int
b3dLoadClientState(int handle, float *vtxData, int vtxSize, float *colorData, int colorSize, float *normalData, int normalSize, float *txData, int txSize) {
    UNIMPLEMENTED();
    return 0;
}

int
b3dDrawArrays(int handle, int mode, int minIdx, int maxIdx) {
    UNIMPLEMENTED();
    return 0;
}

int
b3dDrawElements(int handle, int mode, int nFaces, unsigned int *facePtr) {
    UNIMPLEMENTED();
    return 0;
}

int
b3dDrawRangeElements(int handle, int mode, int minIdx, int maxIdx, int nFaces, unsigned int *facePtr) {
    UNIMPLEMENTED();
    return 0;
}

#endif //B3DX_METAL

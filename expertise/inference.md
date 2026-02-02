# Inference Code Review Expertise

This expertise is injected when ML/DL inference/serving code is detected in the diff.

---

## Additional Focus Areas for Inference Code

### Model State & Mode

- [ ] **Evaluation mode**
  - Is `model.eval()` called before inference?
  - BatchNorm and Dropout behaving as expected?

- [ ] **Gradient computation disabled**
  - Using `torch.no_grad()` or `@torch.inference_mode()`?
  - Memory savings from disabled gradients?
  - `inference_mode` preferred over `no_grad` for new code?

- [ ] **Model loading**
  - Loading to correct device (CPU/GPU)?
  - Handling missing keys or unexpected keys?
  - Using `map_location` for device-agnostic loading?

### Performance & Latency

- [ ] **Batching**
  - Supporting batch inference for throughput?
  - Dynamic batching for serving?
  - Padding handled efficiently?

- [ ] **Model optimization**
  - TorchScript/torch.compile for speedup?
  - ONNX export for deployment?
  - Quantization (INT8/FP16) considered?

- [ ] **Memory efficiency**
  - Model loaded once and reused?
  - Intermediate tensors released promptly?
  - Memory pooling for repeated inference?

- [ ] **Warm-up**
  - First inference latency handled?
  - CUDA kernel compilation cached?
  - JIT compilation warm-up?

### Input Processing

- [ ] **Input validation**
  - Input shape validated before inference?
  - Data type checking?
  - Range/bounds validation?

- [ ] **Preprocessing consistency**
  - Same preprocessing as training?
  - Normalization parameters correct?
  - Image resizing method consistent?

- [ ] **Tokenization (for NLP)**
  - Same tokenizer as training?
  - Max length handling (truncation)?
  - Special tokens added correctly?

### Output Processing

- [ ] **Post-processing**
  - Softmax/sigmoid applied where needed?
  - Thresholding for classification?
  - NMS for object detection?

- [ ] **Output format**
  - Returning appropriate data types?
  - JSON serializable outputs?
  - Consistent response format?

- [ ] **Confidence/probability handling**
  - Calibration considered?
  - Uncertainty quantification?

### Error Handling

- [ ] **Graceful degradation**
  - Handling model loading failures?
  - Timeout handling for long inference?
  - OOM handling?

- [ ] **Input edge cases**
  - Empty input handling?
  - Very long sequences?
  - Corrupted/malformed input?

- [ ] **Fallback mechanisms**
  - Default response when model fails?
  - Retry logic with backoff?

### Serving & Production

- [ ] **Thread safety**
  - Model inference thread-safe?
  - Shared state handled correctly?
  - Request isolation?

- [ ] **Async support**
  - Async inference for I/O bound operations?
  - Proper awaiting of model calls?
  - Concurrent request handling?

- [ ] **Monitoring**
  - Latency tracking?
  - Throughput metrics?
  - Error rate monitoring?
  - Input/output logging (with privacy)?

- [ ] **Resource management**
  - GPU memory limits enforced?
  - Request queuing for overload?
  - Connection pooling?

### Security

- [ ] **Input sanitization**
  - Adversarial input handling?
  - Size limits to prevent DoS?
  - Injection prevention?

- [ ] **Model protection**
  - Model not exposed directly?
  - Rate limiting in place?
  - Authentication for endpoints?

---

## Common Inference Code Issues

### Issue: Gradients not disabled
```python
# BAD: computing gradients during inference
def predict(model, x):
    return model(x)  # Wastes memory on gradient tracking

# GOOD: disable gradient computation
@torch.inference_mode()
def predict(model, x):
    return model(x)
```

### Issue: Model in training mode
```python
# BAD: model might have Dropout/BatchNorm in wrong mode
def serve():
    model = load_model()
    # model.eval() never called!

# GOOD: set eval mode
def serve():
    model = load_model()
    model.eval()
```

### Issue: Loading model on every request
```python
# BAD: loading model repeatedly
def predict(input_data):
    model = torch.load("model.pt")  # Slow!
    return model(input_data)

# GOOD: load once
MODEL = None
def get_model():
    global MODEL
    if MODEL is None:
        MODEL = torch.load("model.pt")
        MODEL.eval()
    return MODEL
```

### Issue: Device mismatch
```python
# BAD: model and input on different devices
model = model.cuda()
output = model(input_tensor)  # input_tensor might be on CPU!

# GOOD: ensure same device
device = next(model.parameters()).device
input_tensor = input_tensor.to(device)
output = model(input_tensor)
```

### Issue: Missing input validation
```python
# BAD: no validation
def predict(image):
    return model(preprocess(image))

# GOOD: validate inputs
def predict(image):
    if image is None:
        raise ValueError("Image cannot be None")
    if image.shape[0] > MAX_SIZE:
        raise ValueError(f"Image too large: {image.shape}")
    return model(preprocess(image))
```

### Issue: Blocking async endpoint
```python
# BAD: blocking call in async handler
async def predict_endpoint(request):
    result = model.predict(request.data)  # Blocks event loop!
    return result

# GOOD: run in thread pool
async def predict_endpoint(request):
    result = await asyncio.get_event_loop().run_in_executor(
        None, model.predict, request.data
    )
    return result
```

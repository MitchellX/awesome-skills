# Training Code Review Expertise

This expertise is injected when ML/DL training code is detected in the diff.

---

## Additional Focus Areas for Training Code

### Gradient & Optimization

- [ ] **Gradient computation correctness**
  - Is `loss.backward()` called correctly?
  - Is `optimizer.zero_grad()` called before backward pass?
  - Any gradient accumulation issues?

- [ ] **Optimizer configuration**
  - Appropriate optimizer choice (Adam, AdamW, SGD)?
  - Learning rate reasonable for the task?
  - Weight decay configuration correct?

- [ ] **Learning rate scheduling**
  - Is scheduler stepping at correct frequency (step vs epoch)?
  - Warmup configured properly?
  - Scheduler compatible with optimizer?

- [ ] **Gradient clipping**
  - Is gradient clipping needed for stability?
  - Clipping applied before optimizer step?
  - Max norm value appropriate?

### Memory Management

- [ ] **GPU memory efficiency**
  - Any unnecessary tensors kept in memory?
  - Using `del` and `torch.cuda.empty_cache()` when needed?
  - Gradient checkpointing for large models?

- [ ] **Batch size considerations**
  - Batch size appropriate for available memory?
  - Gradient accumulation for effective larger batches?

- [ ] **Mixed precision (AMP)**
  - Using `autocast` correctly?
  - `GradScaler` configured properly?
  - Ops that don't support FP16 handled?

### Data Loading

- [ ] **DataLoader configuration**
  - `num_workers` set appropriately?
  - `pin_memory=True` for GPU training?
  - `persistent_workers` for efficiency?
  - `prefetch_factor` considered?

- [ ] **Data pipeline efficiency**
  - Transforms computed on CPU or GPU appropriately?
  - Any blocking I/O in data loading?
  - Caching for repeated access?

- [ ] **Shuffling & sampling**
  - Training data shuffled?
  - Validation data NOT shuffled?
  - Distributed sampler for multi-GPU?

### Model State

- [ ] **train() vs eval() modes**
  - `model.train()` called before training?
  - `model.eval()` called before validation?
  - Impact on BatchNorm and Dropout understood?

- [ ] **Checkpoint saving/loading**
  - Saving optimizer state along with model?
  - Saving scheduler state?
  - Saving epoch/step for resumption?
  - Using `model.state_dict()` not the model directly?

- [ ] **Model initialization**
  - Weights initialized properly?
  - Random seed set for reproducibility?

### Loss Functions

- [ ] **Loss computation**
  - Reduction method appropriate (mean vs sum)?
  - Handling of ignore_index for padded sequences?
  - Multi-task loss weighting correct?

- [ ] **Numerical stability**
  - Using numerically stable implementations?
  - Log-sum-exp tricks where needed?
  - Avoiding division by zero?

### Training Loop

- [ ] **Epoch/step counting**
  - Off-by-one errors in loops?
  - Correct handling of partial batches?

- [ ] **Logging & monitoring**
  - Logging at appropriate frequency?
  - Tracking relevant metrics?
  - TensorBoard/W&B integration correct?

- [ ] **Early stopping & best model**
  - Patience configured reasonably?
  - Saving best model based on validation metric?
  - Metric direction (higher/lower is better) correct?

### Distributed Training (if applicable)

- [ ] **DDP setup**
  - `DistributedDataParallel` wrapped correctly?
  - Model moved to GPU before wrapping?
  - `find_unused_parameters` set if needed?

- [ ] **Gradient synchronization**
  - Gradients averaged correctly across processes?
  - Batch size accounting for world size?

- [ ] **Checkpointing in distributed**
  - Only saving from rank 0?
  - Barrier before and after checkpoint operations?

---

## Common Training Code Issues

### Issue: Gradient not flowing
```python
# BAD: detach breaks gradient
features = encoder(x).detach()  # Gradient won't flow back

# GOOD: keep gradient flow
features = encoder(x)
```

### Issue: Memory leak from storing tensors
```python
# BAD: storing tensors with gradient history
losses.append(loss)  # Keeps entire computation graph

# GOOD: store scalar value
losses.append(loss.item())
```

### Issue: Incorrect DataLoader in distributed
```python
# BAD: no distributed sampler
loader = DataLoader(dataset, shuffle=True)

# GOOD: use distributed sampler
sampler = DistributedSampler(dataset)
loader = DataLoader(dataset, sampler=sampler)
```

### Issue: BatchNorm issues in eval
```python
# BAD: forgetting to switch mode
def validate(model, loader):
    # model still in train mode!
    for batch in loader:
        ...

# GOOD: switch to eval mode
def validate(model, loader):
    model.eval()
    with torch.no_grad():
        for batch in loader:
            ...
```

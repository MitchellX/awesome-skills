# Expertise Auto-Detection Rules

This file defines the rules for automatically detecting which expertise prompts to inject based on the diff content.

## How It Works

1. The skill reads this file to get detection rules
2. For each expertise, it checks if the diff matches `trigger_patterns` OR `file_patterns`
3. If matched, the corresponding `expertise/*.md` file is loaded and injected into reviewer prompts

## Detection Rules

| expertise | trigger_patterns | file_patterns |
|-----------|------------------|---------------|
| training | `loss.backward()`, `optimizer.step()`, `optimizer.zero_grad()`, `DataLoader`, `nn.Module`, `model.train()`, `torch.save`, `checkpoint`, `epoch`, `batch_size`, `learning_rate`, `lr_scheduler`, `gradient`, `backward`, `Trainer` | `*train*.py`, `*trainer*.py`, `*training*.py`, `train.py` |
| inference | `model.eval()`, `torch.no_grad()`, `@torch.inference_mode`, `torch.inference_mode`, `model.predict`, `predictor`, `serving`, `endpoint`, `latency`, `batch_inference` | `*infer*.py`, `*inference*.py`, `*predict*.py`, `*serve*.py`, `inference.py`, `predict.py` |

## Adding New Expertise

To add new expertise (e.g., `distributed`):

1. Create `expertise/distributed.md` with the expertise prompts
2. Add a row to the table above:

```markdown
| distributed | `DistributedDataParallel`, `FSDP`, `torch.distributed`, `deepspeed`, `world_size`, `local_rank`, `all_reduce`, `broadcast` | `*distributed*.py`, `*ddp*.py`, `*parallel*.py` |
```

3. The skill will automatically detect and apply it

## Pattern Matching Notes

- `trigger_patterns`: Regex patterns matched against diff content
- `file_patterns`: Glob patterns matched against changed file paths
- Multiple patterns are OR'd together (any match triggers the expertise)
- Multiple expertise can be detected and applied simultaneously

## Example Matches

### Training Code
```python
# This would trigger 'training' expertise
def train_epoch(model, dataloader, optimizer):
    model.train()
    for batch in dataloader:
        optimizer.zero_grad()
        loss = model(batch)
        loss.backward()
        optimizer.step()
```

### Inference Code
```python
# This would trigger 'inference' expertise
@torch.inference_mode()
def predict(model, inputs):
    model.eval()
    return model(inputs)
```

### Both (Training + Inference in same diff)
```python
# Would trigger BOTH expertise if both patterns found in diff
```

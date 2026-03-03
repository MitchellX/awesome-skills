# Paper Domain Auto-Detection Rules

This file defines detection rules for automatically identifying the paper's domain.

## How Detection Works

1. Read the paper content (all .tex files)
2. Check each domain's `trigger_patterns` against the content
3. If 3+ trigger patterns match, load that domain's expertise file
4. Multiple domains can match simultaneously

## Domains

### Machine Learning (ml.md)

**trigger_patterns:**
- `\b(attention|transformer|self-attention|multi-head)\b`
- `\b(training|fine-tun|pre-train|loss function)\b`
- `\b(GPU|CUDA|distributed|parallel)\b`
- `\b(neural network|deep learning|model architecture)\b`
- `\b(FID|FLOPs|PSNR|accuracy|F1|BLEU|perplexity)\b`
- `\b(ablation|baseline|benchmark)\b`
- `\b(gradient|optimizer|learning rate|batch size)\b`
- `\b(diffusion|generation|latent|VAE|GAN)\b`

**file_patterns:**
- `*.tex` files containing `\usepackage{algorithm}`
- Paper directories with `train.py` or `model.py`

**threshold:** 3 (need at least 3 pattern matches)

---

*Add more domains as needed (e.g., theory.md, systems.md, nlp.md)*

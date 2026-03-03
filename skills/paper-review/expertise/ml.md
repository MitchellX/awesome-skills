# Machine Learning Paper Review Expertise

This expertise is injected when the paper is detected to be in the ML/AI domain.

## Additional Review Criteria

### Experimental Rigor
- Are baselines fair and recent? (not just straw-man comparisons)
- Are hyperparameters reported? (learning rate, batch size, optimizer, schedule)
- Is compute budget reported? (GPU hours, hardware used)
- Are error bars / confidence intervals provided?
- Is the evaluation metric appropriate for the task?
- Are ablation studies sufficient? (each component justified)
- Is the dataset split proper? (no data leakage)

### Reproducibility
- Is the method description sufficient to reimplement?
- Is code/data availability mentioned?
- Are random seeds reported?
- Are preprocessing steps documented?

### Claims vs Evidence
- Do the numbers in the abstract match the tables?
- Are improvements statistically significant or within noise?
- Is "state-of-the-art" claim actually supported by the comparison?
- Are limitations honestly discussed?

### Common ML Paper Issues
- Comparing against outdated baselines
- Cherry-picking metrics or datasets
- Missing wall-clock time comparison (only reporting FLOPs)
- Claiming "efficiency" without actual speedup measurements
- Using different training budgets for method vs baselines
- Overclaiming generalization from limited experiments

### Notation Consistency
- Are tensor dimensions consistently denoted? (B, T, C, H, W, D, etc.)
- Is the same symbol used for the same concept throughout?
- Are all variables in equations defined before first use?

## Trigger Patterns
- attention, transformer, self-attention, multi-head
- training, fine-tuning, pre-training, loss function
- GPU, CUDA, distributed, parallel
- model, neural network, deep learning
- FID, FLOPs, PSNR, accuracy, F1, BLEU
- ablation, baseline, benchmark
- gradient, optimizer, learning rate, batch size
- diffusion, generation, latent, VAE, GAN

## File Patterns
- train.py, model.py, *.yaml (config files)
- Papers with \usepackage{algorithm}

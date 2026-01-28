# Contributing to Flappy Bird with Multitasking & Sound

Thank you for your interest in contributing to the **Flappy Bird with Multitasking & Sound** project. This version of the game is designed as an **advanced educational system-level project**, focusing on multitasking, interrupt handling, and low-level hardware interaction in 16-bit x86 Assembly.

Contributions that improve clarity, correctness, performance, or educational value are highly encouraged.

---

## Scope of Contributions

You may contribute in the following areas:

* Multitasking and scheduler improvements
* PCB structure cleanup or optimization
* Sound system enhancements (PC speaker, melody control)
* Gameplay logic fixes or refinements
* Code readability and commenting
* Documentation and diagrams

This project prioritizes **learning value and correctness** over feature bloat.

---

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Ensure the game assembles and runs correctly in **DOSBox**
4. Create a feature branch:

```bash
git checkout -b feature/short-description
```

---

## Assembly Coding Guidelines

When modifying `Flappy_Bird_with_music.asm`, please follow these rules:

### General

* Use **16-bit real-mode compatible instructions only**
* Preserve register state carefully (push/pop symmetry)
* Restore segment registers unless intentionally changed
* Avoid assembler-specific macros unless necessary

### Multitasking & ISR Rules

* Clearly document **input/output registers** for every ISR
* Do not break **timer ISR atomicity**
* Ensure new tasks properly:

  * Initialize PCB fields
  * Have a valid stack
  * Return control safely
* Avoid long blocking loops inside ISRs

### Sound Task Rules

* Use PIT and speaker ports responsibly (`43h`, `42h`, `61h`)
* Always ensure sound is **disabled on exit**
* Avoid hard-locking the CPU inside sound loops

---

## Commit Guidelines

* Keep commits focused and atomic
* Use descriptive messages

**Good examples:**

* `Refactor PCB initialization for clarity`
* `Fix race condition in timer_music ISR`
* `Improve sound task cleanup on exit`

---

## Testing Requirements

Before submitting a Pull Request:

* Assemble and link without errors or warnings
* Test in DOSBox for:

  * Stable multitasking (no crashes or freezes)
  * Continuous sound playback during gameplay
  * Correct pause / resume behavior
  * Proper restoration of original ISRs on exit

---

## Submitting a Pull Request

1. Push your branch to your fork
2. Open a Pull Request against `main`
3. Clearly describe:

   * What you changed
   * Why it improves the project
   * Any limitations or assumptions

Include screenshots or short recordings if behavior changes.

---

## Code of Conduct

This is an academic and learning-focused project. Be respectful, constructive, and open to feedback.

---

## Questions & Proposals

If you plan a major change (scheduler redesign, new sound engine, etc.), please open an issue first to discuss it.

Happy hacking at the system level!

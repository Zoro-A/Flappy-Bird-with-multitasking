# Flappy Bird with Multitasking & Sound (x86 Assembly)

A **DOS-based Flappy Bird clone written in 16-bit x86 Assembly**, enhanced with **cooperative multitasking and background music**. This version extends the base game by introducing a lightweight process scheduler using **Process Control Blocks (PCBs)** and a **timer-driven context switcher**, allowing gameplay and sound generation to run concurrently.

This project is designed as an **advanced educational demonstration** of low-level systems concepts including multitasking, interrupt-driven scheduling, and direct hardware control.

---

## What This Project Does

* Implements a playable **Flappy Bird-style game** in real-mode x86 Assembly
* Adds **background music** using the PC speaker (PIT + port I/O)
* Uses **multitasking via timer interrupt (INT 8)** to run:

  * Game logic (animation, input, rendering)
  * Sound playback loop (music task)
* Renders graphics directly to **VGA text-mode memory (0xB800)**
* Handles keyboard input via a custom **keyboard ISR (INT 9)**
* Includes pause, resume, scoring, and end-game screens

---

## Why This Project Is Useful

This project is useful for students and low-level developers who want to:

* Understand **cooperative multitasking** without an operating system
* Learn how **context switching** works at the register and stack level
* Study **Process Control Block (PCB)** design and scheduling
* Explore **hardware-level sound generation** using the PC speaker
* Combine **real-time audio** with game logic using interrupts

It is particularly valuable for courses in:

* Computer Organization & Assembly Language
* Operating Systems (introductory multitasking concepts)
* Low-level Systems Programming

---

## Key Technical Concepts Demonstrated

* **Multitasking Scheduler** using:

  * PCB table (`pcb` array)
  * Per-task stacks
  * Round-robin scheduling
* **Timer Interrupt Hook (INT 8)** for task switching
* **Keyboard Interrupt Hook (INT 9)** for real-time input
* **PC Speaker Audio** via:

  * PIT (8253/8254)
  * Ports `43h`, `42h`, `61h`
* **Direct Video Memory Rendering** in VGA text mode

---

## Getting Started

### Prerequisites

You will need:

* **DOSBox** (recommended)
* **MASM** or **TASM** assembler
* A system capable of running **16-bit DOS programs**

---

### Build Instructions

1. Place the source file in your DOSBox working directory:

```
Flappy_Bird_with_music.asm
```

2. Assemble the program:

```bash
masm Flappy_Bird_with_music.asm;
```

3. Link the object file:

```bash
link Flappy_Bird_with_music.obj;
```

4. Run the executable:

```bash
Flappy_Bird_with_music.exe
```

---

## Controls

| Key          | Action                  |
| ------------ | ----------------------- |
| ↑ (Up Arrow) | Bird moves upward       |
| Release ↑    | Bird falls downward     |
| Esc          | Pause game (Y/N prompt) |
| Y            | Quit game               |
| N            | Resume game             |

---

## How Multitasking Works (High-Level)

* Each task is represented by a **Process Control Block (PCB)** containing:

  * Registers
  * Stack pointer
  * Code segment & instruction pointer
* A **custom timer ISR** saves the current task state and restores the next task
* Two main tasks are registered:

  1. **Game animation loop**
  2. **Sound generation loop (`myTask`)**
* The scheduler performs **round-robin context switching** on each timer tick

This allows music to continue playing while the game runs.

---

## Project Structure

```
.
├── Flappy_Bird_with_music.asm   # Game + multitasking + sound implementation
├── README.md                   # Project documentation
└── Docs
     └──CONTRIBUTING.md             # Contribution guidelines
```

---

## Getting Help

If you need help understanding the project:

* Start by reading comments around:

  * `initpcb`
  * `timer_music`
  * `myTask`
* Study how registers and stacks are saved/restored
* Use DOSBox debugger to trace interrupt execution

Recommended topics to review:

* x86 real-mode interrupts
* PIT (8253/8254) timer
* PC speaker programming
* Context switching fundamentals

---

## Contributing

Contributions are welcome.

Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for guidelines.

Suggested enhancements:

* Multiple sound tracks
* Difficulty progression
* Better scheduling fairness
* Visual indicator for sound state

---

## Maintainers

Maintained by:

* **Mahhee Ibn Ahmar Bukhari**

Originally developed as an academic project to demonstrate multitasking in Assembly.


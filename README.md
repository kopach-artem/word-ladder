# Word Ladder Solver using ChatGPT (PowerShell)

This project allows you to solve **Word Ladder** problems using the **OpenAI ChatGPT API** with **PowerShell**. It supports manual queries, predefined tests with expected outputs, and GPT-generated automated test cases. It includes scripts for solving a single transformation, validating known word ladders, and auto-generating test cases using GPT.

## ✅ Features

- Solves any valid word ladder via ChatGPT using `word-ladder.ps1`
- Verifies known word ladders via `manual_test.ps1`
- Generates random test cases with GPT via `auto_chatgpt_test.ps1`
- Saves all test results to auto-numbered report files
- Supports test mode to avoid unnecessary file creation

## 📦 Prerequisites

- PowerShell 5+ on Windows or PowerShell Core on Linux/macOS
- OpenAI API key (for GPT-3.5 or GPT-4 access)
- Git (to clone the repository)

## ⚙️ Setup and Usage

To get started, first clone the repository using `git clone https://github.com/kopach-artem/word-ladder` and navigate into the project folder using `cd <your-repo-folder>`. Once inside, create a file named `.env` in the root directory and paste your OpenAI API key in the format `OPENAI_API_KEY=sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXX`. This file is required for all scripts to access the ChatGPT API. Do not share this file publicly.

Next, to manually solve a word ladder problem, run the script `word-ladder.ps1` using `powershell -ExecutionPolicy Bypass -File .\word-ladder.ps1`. The script will prompt you to enter a start and end word, send a request to ChatGPT, display the resulting transformation, and save the output to a file like `run_1.txt`, `run_2.txt`, and so on.

If you want to test ChatGPT against known word ladder problems with expected transformation sequences, run the script `manual_test.ps1` using `powershell -ExecutionPolicy Bypass -File .\manual_test.ps1`. This script executes 10 predefined test cases, compares the actual GPT output against the expected sequence, and writes the results to `run_manual_test_report_1.txt`, `run_manual_test_report_2.txt`, etc.

To automatically generate test cases using GPT itself, use the `auto_chatgpt_test.ps1` script by running `powershell -ExecutionPolicy Bypass -File .\auto_chatgpt_test.ps1`. This script asks ChatGPT to generate 10 valid word pairs, solves each pair, checks that the first and last words match the expected inputs, and logs the results to `run_auto_test_report_1.txt`, `run_auto_test_report_2.txt`, and so on.

All scripts support test mode internally and avoid generating unnecessary files during batch testing. Reports are formatted with complete input, GPT output, and pass/fail status.

## 📁 Output Files

- `run_N.txt`: raw GPT output for manual runs
- `run_manual_test_report_N.txt`: results of predefined tests with full comparison and verdict
- `run_auto_test_report_N.txt`: results of GPT-generated test cases with correctness check

## 📝 Notes

You can freely expand the number of test cases, change prompts, or modify parsing logic. The project is designed for educational and evaluation purposes to explore GPT’s performance on logical transformation tasks.

# Sept 30 1:33 pm

I have read over the project, and I understand that the way the program works is that initally the user enters a mathematical expression in prefix notation. The result is added to a list using cons, and each result is associated with an ID, starting from 1 for the first result and incrementing for each new result. When a result is calculated, it is printed to the screen with its corresponding history ID.
The program also continuously prompts the user for input and evaluates the expression provided. The user can enter expressions or type quit to exit the program. This is for interactive mode only. In batch mode, the program reads an expression from the command-line arguments or input file (in this simplified version, it's from the command line). The result of the expression is printed, and the program doesn't ask for further input. Lastly from what I know this program will also have ot include error handling.

# Sept 30 7:18 pm

My goal right now is to set up the program and handle whether it runs in interactive or batch mode. I want to write the basic setup for the program which will be including checking if the program is being run in either interactive mode or match mode. I am planning on having a variable "interactive?" that will store whether the programming will be running interactively or in batch mode.

# Sept 30 8:45

I did finish my goal for this session. I added this: #lang racket: This sets the language for the program to Racket. Next I implemented the mode detection. I am using (current-command-line-arguments) to check if the program is in batch mode (via the -b flag) or interactive mode.

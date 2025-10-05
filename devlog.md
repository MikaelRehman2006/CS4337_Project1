# Sept 30 1:33 pm

I have read over the project, and I understand that the way the program works is that initally the user enters a mathematical expression in prefix notation. The result is added to a list using cons, and each result is associated with an ID, starting from 1 for the first result and the IDs are incremented for each new result. When a result is calculated, it is printed to the screen with its corresponding history ID.
The program also continuously prompts the user for input and evaluates the expression provided. The user can enter expressions or type quit to exit the program. This is for interactive mode only. In batch mode, the program reads an expression from the command-line arguments or input file (in this simplified version, it's from the command line). The result of the expression is printed, and the program doesn't ask for further input. Lastly from what I know is that this program will also have to include error handling.

# Sept 30 7:18 pm

My goal right now is to set up the program and handle whether it runs in interactive or batch mode. I want to write the basic setup for the program which is including checking if the program is being run in either interactive mode or match mode. I am planning on having a variable "interactive?" that will store whether the programming will be running interactively or in batch mode.

# Sept 30 8:45

I did finish my goal for this session. I added this: #lang racket: This sets the language for the program to Racket. Next I implemented the mode detection. I am using (current-command-line-arguments) to check if the program is in batch mode (via the -b flag) or interactive mode.

I will be taking a break, and when I come back I will start the next session, which will be about working on parsing the input expression and splitting it into tokens.

# Sept 30 9:00 pm

No thoughts when starting this session, I will give a recap when I end this session on what I have done.

# Sept 30 9:34 pm

I have added code that prints a prompt that asks the user to enter a prefix expression. I used the (read) function to read the user input and then store it in "user-input". If the user enters (+ 1 2), user-input will be interpreted as (+ 1 2) (a list). I also wrote another line to display what the user typed so both I and the user can confirm the input was read correctly.

After this I added a function called "start-program", this code uses an if statment to check the boolean value of "interactive?". If it true, it calls process-expression (which asks the user to enter an expression and evaluates it). Then it calls start-program again recursively, meaning it will prompt the user for input again, and it keep doing it until the user types quit. If interactive? is false, it will only call "process-expression", then quit.

# Oct 2 11:05 pm

My current goal is to figure out and start the implementation of error handling, more specifically when evaluating the user input. The implentation is supposed to catch exceptions. Other than this I have no other thoughts.

# Oct 2 11:48

This is the end of my session, I had to research on how to do exceptions as it was confusing to me. I first used a function called with-handlers which is able to catch exceptions that occur inside of a block of code. I was confused about how the function with-handlers worked in terms of why it needed a predicate. The predicate I used was the function "exn:fail?", which checks if the exception is a failure type. If the exception satifies the predicate I put in, it calls (lambda (e) ...). This just displays an error message.

# Oct 5 1:17 AM

I am looking to get started with history related code. No other specific thoughts.

# Oct 5 2:36 AM

I added a history parameter to track all previous results. Every time an expression is successfully evaluated, the result is added to the front of the history list, and it is displayed with a history ID. Also the original process-expression function now returns the updated story so it can be used in subsequent evaluations.

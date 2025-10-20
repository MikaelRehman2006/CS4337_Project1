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

# Oct 19 5:30 PM

So right now my start-program is called again with the old history (the list before the new result was added). I have to fix this by storing the returned value we get from process-expression and then using it in a recursive call. After this I want to allow users to reuse previous results by typing something like: (+ $1 5):
This means:
$1 should be replaced with the first result in history
$2 should be replaced with the second, and so on.

# Oct 19 7:30 pm

What I have completed in this session was that I firstly updated the programs main loop so that each time an expression is evaluated, the updated history list is then passed forward to the next iteration. This change makes sure that the previously computed results are stored and also preserved throughout the session

After this I started and essentially finished the history reference support (%n)

The first step I did was I created the helper function get-history-index, which detects symbols like $1, $2, etc., and extracts their numeric part.
The next step I did was that I added the recursive replace-history-refs function that walks through the user’s expression and substitutes each $n symbol with the corresponding value from the history list.
The last step I did was I integrated this placement step into process-expression, so for example expressions like (+ $1 5) are able to correctly use the stored values before evaluation.

At this point, the calculator is fully supporting

- Continuous expression evaluation (interactive mode)
- Safe error handling with with-handlers
- Persistent result history
- $n substitutions for reusing previous outputs

In the next session, which I am hoping to be later today, I am planning on doing some polishing. This would be adding a way for the user to quit (e.g., if input is 'quit or 'exit). I will also be adding a way print the full history before exiting. Lastly, I may add some extra stuff if it is needed, and do some testing to fix some potential bugs,

# Oct 19 8:15pm

Same thoughts as what I mentioned when I ended last session, starting now

# Oct 19 12:01

I have made many more changes and additions after testing:

I added more for the quit and exit flow. I added the support for quit/exit in interactive mode. On quit the program prints the full history, which is IDs and values, and then it exits cleanly.

For prompting and output rules, the prompt only appears in interactive mode. In batch mode there is no prompt and the program only prints the results or Error: lines.

For batch over multiple expressions, I extended the batch mode to process all expressions until EOF (not just one). Added an EOF guard so #<eof> is not treated as an expressions.

I made a fix regarding the history stability of errors, I updated the error handler to return the existing history after printing Error: Invalid Expression, so the loop keeps running without crashing.

I also replaced Racket’s eval with a small recursive evaluator that enforces:

- and \*: binary only (exactly two operands)
  /: binary integer division via quotient (both operands must be integers; error on divide-by-zero)
  -: unary negation only (exactly one operand; no subtraction)
  Any wrong arity, non-integer for /, bad operator is a Error: Invalid Expression

Next I made it so immediate results are printed as floats using real->double-flonum.

$n substitution remains in place and now works in batch as well.

Lastly, I did a general polish where interactive loop carries the history forward, the batch history starts with a fresh history per run, and error handling an output formatting are consistent across modes.

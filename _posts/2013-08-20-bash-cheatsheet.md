---
layout: post
title: "Bash cheatsheet"
description: ""
category: cheatsheet
tags: linux shell
---
{% include JB/setup %}

#### Arguments ####

| arg  | explanation                                                         |
| -----| ------------------------------------------------------------------- |
| $\_  | The args of last command.                                           |
| $#   | Number of args.                                                     |
| $0   | Pathname of the program being executed.                             |
| $$   | Process id of current command.                                      |
| $!   | Process id of the last job put into the background.                 |
| "$@" | A list of the args is most commonly used.                           |

{% highlight bash %}
# access to all args
count=1
while [[ $# -gt 0 ]]; do
    echo "Argument $count = $1"
    count=$((count + 1))
    shift
done
{% endhighlight %}

#### If test ####

* `if [test];then xxx;fi`
 _*man test*_ for detailed options

* `if((arithmetic exp));then xxx;fi`

* `if [[ expression =~ regex ]];then xxx;fi` `if [[ expression == wildcards_allowed ]];then xxx;fi`

| Operation | test | \[\[\]\] and (()) |
| --------- | ---- |:-----------------:|
| And       | -a   | &amp;&amp;        |
| Or        | -o   | &#124;&#124;      |
| Not       | !    | !                 |

####  Variables ####
| command                                    | explanation                                                                                                                                                                                  |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `echo "${foo}bar"`                         |                                                                                                                                                                                              |
| `echo ${foo:-"substitute value if unset"}` | If foo is unset or is empty, this expansion results in the value of word.                                                                                                                    |
| `echo ${foo:="default value if unset"}`    | If foo is unset or empty, this expansion results in the value of word. In addition, the value of word is assigned to foo.                                                                    |
| `echo ${foo:?"parameter is empty"}`        | If parameter is unset or empty, this expansion causes the script to exit with an error, and the contents of word are sent to standard error.                                                 |
| `echo ${foo:+"substitute value if set"}`   | If parameter is unset or empty, the expansion results in nothing. If parameter is not empty, the value of word is substituted for parameter; however, the value of parameter is not changed. |
| `${!prefix@}`                              | Return the names of variables start with prefix.(bash)                                                                                                                                       |
| `${#parameter}`                            | Expands into the length of the string contained by parameter.                                                                                                                                |
| `${parameter:offset:length}`               | Sub string.If the value of offset is negative, it is taken to mean it starts from the end of the string rather than the beginning.                                                           |
| `${parameter#wildcard_pattern}`            | Removes the shortest match from the start.                                                                                                                                                   |
| `${parameter##wildcard_pattern}`           | Removes the longest match from the start.                                                                                                                                                    |
| `${parameter%wildcard_pattern}`            | Removes the shortest match from the end.                                                                                                                                                     |
| `${parameter%%wildcard_pattern}`           | Removes the longest match from the end.                                                                                                                                                      |
| `${parameter/wildcard_pattern/string}`     | Only first occurrences replaced.                                                                                                                                                             |
| `${parameter//wildcard_pattern/string}`    | All occurrences are replaced.                                                                                                                                                                |
| `${parameter/#wildcard_pattern/string}`    | From start.                                                                                                                                                                                  |
| `${parameter/%wildcard_pattern/string}`    | From end.                                                                                                                                                                                    |
| `declare -u upper declare -l lower`        | Upper/Lower string.                                                                                                                                                                          |
| `declare -a array`                         | Declare an array.                                                                                                                                                                            |
| `declare -A dict`                          | Declare a dict.                                                                                                                                                                              |
| `${parameter,,}`                           | Expand the value of parameter into all lowercase.                                                                                                                                            |
| `${parameter,}`                            | Expand the value of parameter changing only the first character to lowercase.                                                                                                                |
| `${parameter^^}`                           | Expand the value of parameter into all uppercase letters.                                                                                                                                    |
| `${parameter^}`                            | Expand the value of parameter changing only the first                                                                                                                                        |
| `$((base#number))`                         | Number is in base.                                                                                                                                                                           |
| `$(( a**b ))`                              | Exponentiation.                                                                                                                                                                              |
| `${array[@]}`                              | All list items.                                                                                                                                                                              |
| `${#a[@]}`                                 | Array length.                                                                                                                                                                                |
| `${!array[@]}`                             | All list indexes.                                                                                                                                                                            |
| `{exp1; exp2; [exp3; ...]}`                | Group commands.Faster and require less memory comparing to subshell                                                                                                                          |
| `(exp1; exp2; [exp3; ...])`                | Subshell commands which won't change environment variables.                                                                                                                                  |
| `<(list)`                                  | Produce stdout.                                                                                                                                                                              |
| `>(list)`                                  | Produce stdin.                                                                                                                                                                               |
| `trap argument signal [signal...]`         | Where argument is a string which will be read and treated as a command and signal is the specification of a signal that will trigger the execution of the interpreted command.               |

#### Miscellaneous ####

* `wait pid` This causes the parent script to pause until the child script exits.
* `IFS=":" read user pw uid gid name home shell <<< "$file_info"` *IFS* : words seperator, *<<<* : redirect val to stdin.
* `#!/bin/bash -x` to enable tracing and `PS4='$LINENO +'` to show line number.
* `set -x #Turn on tracing` and `set +x #Turn off tracing`
*  Embed a body of text into our script and feed it into the standard input of a command.If `<<-` is used instead of `<<`, leading tabs will be ignored.

{% highlight bash %}
cat << EOF
    some text here
EOF
{% endhighlight %}

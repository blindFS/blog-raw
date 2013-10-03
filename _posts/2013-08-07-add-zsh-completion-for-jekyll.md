---
layout: post
title: "Add zsh completion for jekyll"
description: ""
category: jekyll
tags: linux shell jekyll
---
{% include JB/setup %}

### intension

I am interested in the details of zshell's amazing completion.However it seems to be quit complicated so it may take me a lot of time
to learn about it.

`Don't panic!`

I decide to try something simple while learning the basic first and catch up with the rest later on when I get bored.
I can't find any existing zsh completion for **jekyll** cli which seems to be simple enough,so I tried it myself.

#### things to be done in order to use user defined completion

1. Add your path of **\_command** to **$fpath**.
2. Add `autoload -U compinit` to **.zshrc** or any sourced configuration file.
3. Add `compinit` to that file too.

#### complete options that I know

* **menu_complete**

On an ambiguous completion, instead of listing possibilities or beeping, insert the first match immediately. Then when completion is requested again, remove the first match and insert the second match, etc. When there are no more matches, go back to the first one again. reverse-menu-complete may be used to loop through the list in the other direction.

* **complete_in_word**

If unset, the cursor is moved to the end of the word if completion is started. Otherwise it stays where it is and completion is done from both ends.

* **auto_menu**

Automatically use menu completion after the second consecutive request for completion, for example by pressing the TAB key repeatedly. This option is overridden by MENU_COMPLETE.

In my **.zshrc** I just set complete\_in\_word and auto\_menu

#### \_jekyll
I believe there is a better way to do this,but I just have dived so far.Anyway,it works.

{% highlight sh linenos %}
#compdef jekyll

local ret=1 state

local -a common_ops
common_ops=(
  {-v,--version}"[Display version information]"
  {-h,--help}"[Display help documentation]"
  {-t,--trace}"[Display backtrace when an error occurs]"
  {-p,--plugins}"[Plugins directory (defautls to ./_plugins)]: :_directories"
  {-s,--source}"[Source directory (defaults to ./)]: :_directories"
  {-d,--destination}"[Destination directory (defautls to ./_site)]: :_directories"
  "--layouts=[Layouts directory (defaults to ./_layouts)]: :_directories"
  "--safe=[Safe mode (defaults to false)]"
)

typeset -A opt_args
_arguments \
  ':subcommand:->subcommand' \
  $common_ops \
  '*::options:->options' && ret=0

case $state in
  subcommand)
    local -a subcommands
    subcommands=(
      "build:Build your site"
      "docs:Launch local server with docs for jekyll"
      "doctor:Search site and print specific deprecation warnings"
      "help:Dislplay global or [command] help documentation"
      "import:Import your old blog to Jekyll"
      "new:Creates a new Jekyll site scaffold in PATH"
      "serve:Serve your stie locally"
    )

    _describe -t subcommands 'jekyll subcommand' subcommands && ret=0
  ;;

  options)
    local -a args
    args=(
      $common_ops
    )

    local -a config
    config=(
      "--config[Custome configuration file]: :_files"
    )
    local -a help
    help=(
      {-h,--help}"[Display help information]"
    )
    local -a build
    build=(
      {-w,--watch}"[Watch for changes and rebuild]"
      "--limit_posts[Limits the number of posts to parse and publish]"
      "--future[Publishes posts with a future date]"
      "--lsi[Use LSI for improved related posts]"
      "--drafts[Render posts in the _drafts folder]"
    )

    case $words[1] in
      help)
        args=()
        compadd "$@" build docs doctor help import new serve
      ;;

      build)
        args+=(
          $build
          $config
        )
      ;;

      docs)
        args=(
          {-p,--port}"[Port to listen on]: :_ports"
          {-u,--host}"[Host to bind to]: :_hosts"
          $help
        )
      ;;

      doctor)
        args+=(
          $config
        )
      ;;

      import)
        args=(
          "--source[Source file or URL to migrate from]:url"
          "--file[File to migrate from]: :_files"
          "--dbname[Database name to migrate from]:database"
          "--user[Username to use when migrating]:user"
          "--pass[Password to use when migrating]:password"
          "--host[Host address to use when migrating]:url"
          $help
        )
      ;;

      new)
        args=(
          ": :_directories"
          "--force[Force creation even if PATH already exists]"
          "--blank[Creates scaffolding but with empty files]"
          $help
        )
      ;;

      serve)
        args+=(
          $build
          $config
          {-P,--port}"[Port to listen on]: :_posts"
          {-H,--host}"[Host to bind to]: :_hosts"
          {-b,--baseurl}"[Base URL]:url"
        )

    esac

    _arguments $args && ret=0
  ;;
esac

return ret
{% endhighlight %}

# Pglet client for Bash

[Pglet](https://pglet.io) (*"piglet"*) is a rich user interface (UI) framework for scripts written in PowerShell or any other language. 
Pglet renders web UI, so you can easily [build web apps](https://pglet.io/docs/quickstart) with Bash.
Knowledge of HTML/CSS/JavaScript is not required as you build UI with [controls](https://pglet.io/docs/reference/controls). Pglet controls are built with [Fluent UI React](https://developer.microsoft.com/en-us/fluentui#/controls/web) to ensure your programs look cool and professional.

## Requirements

* Bash, Zsh on Linux or macOS. Windows is not supported.

## Installation

Download `pglet.sh` helper script from our website:

    curl -O https://pglet.io/pglet.sh

## Hello, world!

Create `hello.sh` with the following content:

```bash
. pglet.sh

pglet_page
pglet_send "add text value='Hello, world!'"
```

Run `sh hello.psh` and in a new browser window you'll get:

![Sample app in a browser](https://pglet.io/img/docs/quickstart-hello-world.png "Sample app in a browser")

Here is a local page served by an instance of Pglet server started in the background on your computer.

## Make it web

Add `PGLET_WEB=true` before `pglet_page` call:

```posh
. pglet.sh

PGLET_WEB=true pglet_page
pglet_send "add text value='Hello, world!'"
```

This time page will be created on [Pglet hosted service](https://pglet.io/docs/pglet-service).

Read [Bash tutorial](https://pglet.io/docs/tutorials/bash) for further information and more examples.
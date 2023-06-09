#Naro 

*Currently, this piece of software is in major development and is not fully implemented. Please expect breaking changes. Originally, I was planning to have a working program by April 9, 2023, but that has now changed to the end of April.*

[Marpa](https://metacpan.org/pod/Marpa::R2), created by Jeffery Kegler, allows anyone to parse CFG (Context Free Grammars) in perl. It will parse pretty much any syntax you give it. 

However, it can be difficult to write languages in Marpa's custom DSL. When writing Welkin, my own custom language, I wound up having a larger syntax than I expected. Not only was this difficult for experiments, but in the long-term, I realized it was difficult to maintain. 

Naro aims to solve these problems. Here's an overview of what it does:

* Syntax: it expands shorthands commonly found in EBNF and allows you to add custom macros. You don't need to write everything manually in your syntax; you can have Naro expand out as needed!
* Semantics: you can easily add and maintain Marpa actions to your syntax. *Instructions: WIP.* Simply make a perl module containing each action, a list of rule-action pairs, and give it to Naro. Naro will then generate a list of actions an apply them to your syntax.

You can use Naro via a CLI or as a library. You should have everything you need with the CLI, though you will need to use Naro::Actions to implement your own actions. Feel free to use any other module files. Ultimately, the output of Naro is readable: it's just a longer syntax that does some of the boilerplate for you. You can edit the new syntax as you like, but it's easier to manage it with Naro (and even your own tools).

See CLI options using `--help` (NOT currently implemented).

# Installing

*This section is a work in progress.*


## CPAN

## Build from Source


# Why the name "Naro"?

Naro is shorthand for [Naropa](https://en.wikipedia.org/wiki/Naropa), who was a Buddhist Monk and the teacher of Marpa Lotsawa. Kegler named his program after ["Marpa the Translator."] (https://metacpan.org/pod/Marpa::R2#Why-is-it-called-"Marpa"?). Inspired by Kegler, I thought I would loosely carry out the same Buddhist theme.


# Potiential New Features
Feel free to raise an issue to request new features. Here is a list I may add in the future, though I hope to keep Naro as stable as possible.

- [] Events: manage custom parsing for L0 rules with a list of events, similar to managing actions.

# Contact

**Author:** Oscar Bender-Stone

**Github:** oscar-benderstone

**Email:** <oscarbenderstone@gmail.com>

**Main Website for Updates:** https://logsofhumanisticlogic.wordpress.com/


# Contributing
*This is largely a work in progress. Please contact me if you would like to contribute. You can see new updates for the project at my blog: https://logsofhumanisticlogic.wordpress.com/.


# COPYRIGHT AND LICENSE

This software is Copyright (c) 2023 by Oscar Bender-Stone.

This is free software, licensed under:

The MIT (X11) License


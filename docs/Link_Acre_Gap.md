# Link-Acre gap analysis

It was decided to re-evaluate Link and do a gap analysis to find out what work remains to be done before Acre can build on top of Link instead of its own implementation. This document will list the issues found and recommendations for a separation of domains for the 2 tools.

## Array handling (NC=2)

Link doesn't handle names of class 2. It was agreed that link should handle them, but that care should be taken so as to make it non-greedy with this name class. If a name is edited in the workspace and it doesn't exist on file, no file is created. It must be explicitly tracked (using a `]ACRE.SetChanged` equivalent) to put it on file. Subsequent changes would then be tracked. This ensures that dynamic variables (as compared to application constants) are not written to file if modified with the editor while tracing.

A similar issue may arise with locally defined dfns, but may be harder to identify and prevent. Consider the tradfn below. If tracing, the dfn `dup` can be edited (in its own editor) after definition on line 1. On fix this will create a file for `dup`.

```
[0] r←Foo arg;dup
[1] dup←{⍵ ⍵}
[2] r←dup arg
  
```

## Case coding

Link doesn't have any case coding yet, but it will be implemented. An issue with using the hex format was raised as this may in itself be represented with different casing on a case sensitive OS:

```
TEST-f.charmat
TEST-F.charmat
```

It was suggested that an octal system be used instead to avoid the use of alpha characters.

| hex         | octal        |
| ---         | ---          |
| TEST-f      | TEST-17      |
| Typing-1    | Typing-1     |
| getMAX-38   | getMAX-70    |
| OctalMAX-e1 | OctalMAX-341 |

Using hex or octal encoding ensures a faster encoding/decoding without an upper limit on name length (decimal can be used for names up to 52 characters). Octal would increase the case code somewhat (negligible) and arguable make it safer to use.

## File extensions

Link currently only supports one extension at a time (with an optional switch to provide the extension to use, with default=`.dyalog`). This will be changed to match the file extensions used by Acre, i.e:


| Acre        | Link        |
| ---         | ---         |
| **.array**  | **.apla**   |
| .aplf       | .aplf       |
| .aplo       | .aplo       |
| .apln       | .apln       |
| .aplc       | .aplc       |
| .apli       | .apli       |
| .charlist   | .charlist   |
| .charmat    | .charmat    |
| .charstring | .charstring |

Note: Link will support Dyalog's own array notation natively once implemented. Until then Acre can register its own handler to ensure arrays are written to file using Acre's array notation.

In addition, link will be changed to accept a list of file extensions that will be tracked to allow user defined hooks to deal with additional extensions.

## System variables

Link does nothing with namespace scoped system variables such as `⎕IO`, `⎕ML` etc. It was agreed that this is something that belongs in the domain of a project manager such as `Acre` to take care of.

## APLAN

Dyalog is still working on their implementation. Once it is completed, link will use it to serialise arrays on first export and subsequently only if explicitly asked to. (Will the integrated editor support aplan?)

Until then Acre would need to implement a hook to handle `.array` files

## File System Watcher - Tracking

Link currently supports a file system watcher on the Windows platform only. This will be extended to support all platforms.

Link will (as Acre has) implement a command to manually request a refresh as an alterantive to the file watcher.

## Interpreter's internal fix handler

Link uses ⎕FIX with a file uri to load code. This causes the interpreter's built in prompt to appear on fix. It shouldn't.

## Conclusion

There are some showstoppers that prevent Acre from being built on top of link today, but once they have been resolved work can commence on an Acre-on-Link branch. The critical items are:

* File extensions - being able to define which file extensions to track
* Case coding

The remaining features and outstanding bugs can be worked on in parallel.
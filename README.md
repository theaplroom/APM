# APM - APL Package Manager

## Introduction

APM aims to provide a complete framework for sharing APL code. 

A proof of concept has been implemented by using JavaScript's own package management framework: [npmjs](https://docs.npmjs.com/). This is a largely un-opinionated framework and after some experimentation it proved to be easy to set up and use for APL code as well. APM was built on top of the following components:

* [verdaccio](https://www.verdaccio.org/) - A private npm registry. This can be installed locally (on your own machine or an office server) and/or in the cloud. 

  It can also be configured to act as a proxy, so you can host packages in a private registry with a fallback strategy on a public registry.

* [pnpm](https://pnpm.js.org/en/) - An efficient npm client that organises package dependencies in a fast, secure and predictable way.

* [Acre-Desktop](https://github.com/the-carlisle-group/Acre-Desktop) - An APL project framework developed and maintained by The Carlisle Group.

* [Dyalog](https://www.dyalog.com) - APM requires Dyalog v17.0.

## Installation

To start using APM you will need to install the client-side components in addition to the APM script from this repository.

### NodeJS & npm

1. Download and install [nodejs](https://nodejs.org/en/). This includes both the node framework and the npm client which are required to interact with the registry.

2. Open a command prompt and verify that the installation was successful by issuing the command `npm -v`. This should return the current version of the npm client.

### pnpm

3. Now install version 2 of pnpm by issuing the command `npm i pnpm@2 -g`.

4. Verify the installation with `pnpm -v` which should return the version number of the pnpm client.

### Acre-Desktop

Follow the instructions on [Acre-Dektop's project page](https://github.com/the-carlisle-group/Acre-Desktop).

### APM

5. Download the `APM.dyalog` script and install it as a user command for Dyalog. 

   If you place the script in `C:\Users\me\Documents\MyUCMDs\APM.dyalog` it will be found by any 17.0 installation because from 17.0 onwards this folder is one of the places scanned for user commands anyway.

   If you want to put it into, say, `C:\elsewhere` then you must add this path to the list of folders scanned for user commands by something like this:

   ```
         ]settings cmddir ,C:\elsewhere
   ```

### verdaccio

A public registry is hosted on <https://apm.theaplroom.com/> and you can immediately test the setup by trying to create an account there. 

Optionally, you can run your own registry by installing verdaccio and running it. To do that, open a new command shell and execute the following 2 commands (see instructions on the [verdaccio project's page](https://github.com/verdaccio/verdaccio)):

1. Install verdaccio with `pnpm i -g verdaccio`

1. Run it with `verdaccio`

To test the registry, create an account by following these steps:

1. Set the default registry to use by issuing `pnpm config set registry https://apm.theaplroom.com/`. This will only need to be done once and will be remain until changed again.

1. To create an account on the registry, issue `pnpm login`. You will be prompted for a username, password and email.

## Usage

### Create your first Project

To get started, we'll create a project called `MyProject` in the directory `/path/to/projects/`. When following the instructions replace the name and path with whatever you like and/or is appropriate on your machine. 

In a Dyalog 17.0 session, create a new project by calling:

```
      ]APM.CreateProject /path/to/projects/MyProject #.MyProject
Added script "quadVars"
Project my-project created
Current directory set to C:/Users/gil/MyProject/
Install packages using ]APM.AddPackage                                  
```

This will create a project folder on disk and also set it as the current directory for the duration of the session. It also opens the project and tracks changes to it using Acre. We can confirm that it works by creating a function in the project space:

```
      )ED MyProject.Hello
```

And write a few lines:

```
r←Hello name

r←'Hello ',name
```

Now fix the function and you should see a message from Acre in the session:

```
Saved: #.MyProject.Hello
```

Let's surprise the user by adding the number of days until next Easter in the above function. Is there a package that could help us with that?

```
      ]APM.FindPackage date
NAME        | DESCRIPTION         | AUTHOR      | DATE       | VERSION  | KEYWORDS
dateandtime | DateAndTime offers… | =Kai Jaeger | 2018-07-25 | 1.5.2    | date time APL
```

Looks like there is a date package. To install a package we simpy call `]APM.AddPackage` with a list of package names to install:

```
      ]APM.AddPackage dateandtime
Packages: +1
+
Resolving: total 1, reused 1, downloaded 0, done

dependencies:
+ dateandtime 1.5.2
```

This will install the latest version available of the dateandtime package in our project folder. We now refresh the workspace by running `]APM.loadproject .`

This checks the project folder for dependencies and makes sure to link them into the project space in the workspace.

With the package added and the project reloaded we can now edit the function again and extend it.

```
      )ED MyProject.Hello
```

Add the 3 lines in the bottom.

```
 r←Hello name;easterDays;nextEaster

 r←'Hello ',name

 easterDays←DateAndTime.(DateTime2DayDecimal Easter 0 1+1↑⎕TS)
 nextEaster←0~⍨0⌈⌊easterDays-DateAndTime.Timestamp2DayDecimal ⎕TS
 r,←'. Next Easter is coming up in ',(⍕nextEaster),' days.'
```

Fix the function and try it out:

```
Saved: #.MyProject.Hello
      #.MyProject.Hello 'Gil'
Hello Gil. Next Easter is coming up in 269 days.
```

We can inspect the workspace structure by issuing the command `]map`.
```
      ]map
#
·   MyProject
·   ·   ∇ Hello
·   ·   AcreConfig → #.[Namespace]
·   ·   DateAndTime → #.__packages.dateandtime_1_5_2.DateAndTime
·   ·   __apm → #.[Namespace]
·   ·   quadVars
·   __packages
·   ·   dateandtime_1_5_2
·   ·   ·   AcreConfig → #.[Namespace]
·   ·   ·   DateAndTime [Class]
·   ·   ·   __apm → #.[Namespace]
```

Here we see our project space `MyProject` in the root and also that it contains a function `Hello`, three references to other spaces and finally a namespace called `quadVars`. 

Note how the package `DateAndTime` we've added  has been installed in a separate tree called `__packages`, and that a reference has been created to it in our project space. This is how packages are made available to the dependant project.

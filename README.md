# APM - APL Package Manager

## Introduction

APM aims to provide a complete framework for sharing APL code. A proof of concept has been implemented by using JavaScript's own package management framework: [npmjs](https://docs.npmjs.com/). This is a largely un-opinionated framework and after some experimentation it proved to be easy to set up and use for APL code as well. APM was built on top of the following components:

* [verdaccio](https://www.verdaccio.org/) - A private npm registry. This can be installed both locally (on your own machine or in office server) and/or in the cloud. It can also be configured to act as a proxy, so you can host packages in a private registry with a fallback strategy on a public registry.

* [pnpm](https://pnpm.js.org/en/) - An efficient npm client that organises package dependencies in a fast, secure and predictable way.

* [Acre-Desktop](https://github.com/the-carlisle-group/Acre-Desktop) - An APL project framework developed and maintained by The Carlisle Group.

* [link](https://github.com/Dyalog/link) - A Dyalog tool to load and synchronise source code from a folder into a namespace in the active workspace.

## Installation

To start using APM you will need to install the client-side components in addition to the APM script in this repository.

### NodeJS & npm

1. Download and install [nodejs](https://nodejs.org/en/). This includes both the node framework and the npm client which are required to interact with the registry.

1. Open a command prompt and verify that the installation was successful by issuing the command `npm -v`. This should return the current version of the npm client.

### pnpm

1. Now install version 2 of pnpm by issuing the command `npm i pnpm@2 -g`.

1. Verify the installation with `pnpm -v` which should return the version number of the pnpm client.

### Acre-Desktop

Follow the instructions on [Acre-Dektop's project page](https://github.com/the-carlisle-group/Acre-Desktop).

### APM

1. Download the `APM.dyalog` script and install it as a user command for Dyalog.

### verdaccio

A public registry is hosted on https://apm.theaplroom.com/ and you can immediately test the setup by trying to create an account there. Optionally, you can run your own registry by installing verdaccio and running it. To do that, open a new command shell and execute the following 2 commands (see instructions on the [verdaccio project's page](https://github.com/verdaccio/verdaccio)):

1. Install verdaccio with `pnpm i -g verdaccio`

1. Run it with `verdaccio`

To test the registry, create an account by following these steps:

1. Set the default registry to use by issuing `pnpm config set registry https://apm.theaplroom.com/`. This will only need to be done once and will be remain until changed again.

1. To create an account on the registry, issue `pnpm login`. You will be prompted for a username, password and email.

## Usage

To 
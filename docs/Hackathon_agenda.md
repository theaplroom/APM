# Acre-Link Hackathon (Bramely, 19-20 Nov 2018)

The assumption is that Dyalog's implementation of Link will form the starting code base for a low level tool to map between the file system domain and the active workspace domain. A list of issues and goals has already been drawn up in a separate [gap analyis](Link_Acre_Gap.md).

The roles of Link and Acre (and APM?) will need to be established. The workgroup is to decide on and document:

* Link

  * requirements - both for Acre and other potential tools
  * API - to support both UCMD and directly from other tools

* Acre

  With Link eventually handling the mapping between domains, what will be left in Acre is the definition of a project. Acre has also touched on the concept of packages with a very basic implementation.

  * any changes to the Acre project definition?
  * should Acre take on the role of a package manager?

* APM

  It has been agreed that APL should have its own implementation of a package manager and the associated registry of packages.

  * Package definition - what defines a package and what metadata is required
  * Registry - implemented as a git repository seems to work well for Julia
  * other tools that this would require:
    * zip
    * git
    * semver


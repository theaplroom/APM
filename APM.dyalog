:Namespace APM
⍝ User Command to manage packages - APL Package Manager

    ⎕IO←1 ⋄ ⎕ML←1
    NM←'APM'
    RS←'#.__packages.' ⍝ target root space for packages (dependencies)
    SRV←'https://apm.theaplroom.com'

    ∇ r←List;c
      r←⍬
   ⍝ Name, group, short description and parsing rules
     
      c←⎕NS ⍬
      c.Name←'FindPackage'
      c.Desc←'Search registry for packages'
      c.Parse←'-registry='
      r,←c
     
      c←⎕NS ⍬
      c.Name←'AddPackage'
      c.Desc←'Search registry for packages'
      c.Parse←'-registry= -dev'
      r,←c
     
      c←⎕NS ⍬
      c.Name←'CreateProject'
      c.Desc←'Create project and initialise with APM'
      c.Parse←'-target= -registry='
      r,←c
     
      c←⎕NS ⍬
      c.Name←'OpenProject'
      c.Desc←'Open project into active workspace'
      c.Parse←'-target= -registry='
      r,←c
     
      r.Group←⊂NM
     
    ∇

    ∇ {r}←Run(Cmd Input);ns;cfg
      r←''
      :Select Cmd
      :Case 'AddPackage'
          r←Input.registry add Input.Arguments Input.dev
          cfg←loadProject'.'
      :Case 'FindPackage'
          r←Input.registry find⊃Input.Arguments
      :Case 'CreateProject'
          cfg←createProject 2↑Input.Arguments
          r←''
          r,←⊂'Project ',cfg.name,' created'
          r,←⊂'Current directory set to ',cfg.folder
          r,←⊂'Install packages using ]APM.AddPackage'
          r
     
      :Case 'OpenProject'
          cfg←loadProject(⊃Input.Arguments)Input.target
          r,←⊂'Project ',cfg.name,' opened'
          r,←⊂'Current directory set to ',cfg.folder
     
      :EndSelect
      r←⊃,/r,¨⎕UCS 13
    ∇

    ∇ r←level Help Cmd
      :Select Cmd
      :Case 'OpenProject'
          r←']',NM,'.Load path/to/project'
     
      :EndSelect
    ∇

      add←{
          pkgs dev←⍵
          ⍺ npmExec'install',(⊃,/' ',¨pkgs),dev/' --save-dev'
      }


      find←{
          ⍺ npmExec'search ',⍵
      }

      json←{
          ⎕JSON⍠'Compact' 0⊢⍵
      }

      les←{
          ⍵~'' 0      ⍝ lose empty items
      }

      npmExec←{
          reg←(⎕IO+0≡⍺)⊃⍺ SRV
          utf8¨⎕SH'pnpm ',⍵,' --registry=',reg
      }

      nsEnc←{
          (n v)←(RS,⍵.name,'_')(⍵.version)
          ⎕D∊⍨⊃v:n,'_'@{⍵∊'.-'}v
          n,0(7162⌶)v
      }

      tgtSpace←{
          top tgt ps←⍵
          ~top:nsEnc ⍺
          tgt≢0:tgt
          ~0∊⍴ps:'#.',ps
          ''
      }

      utf8←{
          'UTF-8'⎕UCS ⎕UCS ⍵
      }

      readCfg←{
          s←#.⎕NS''
          s.folder←⊃1 ⎕NPARTS ⍵
          s.main←''
          s.name←''
          s.projectSpace←''
          s.version←''
          r←{'s'⎕NS json⊃⎕NGET ⍵}⍣(~0∊⍴⍵)⊢⍵
          s.nspath←nsEnc s
          s
      }

      loadDependencies←{
          depDirs←⊃¨1 ⎕NPARTS¨(⊂⍵.folder),¨'node_modules/' '../'
          ~∨/m←⎕NEXISTS depDirs:⍵
          dir←⊃m/depDirs
          dirs←les⊃7 ⎕NINFO⍠('Wildcard' 1)('Follow' 0)⊢dir,'*'
          0∊⍴dirs:⍵
          dirs←(⊂dir){'/:'∨.=⍨2↑⍵:⍵ ⋄ ⍺,⍵}¨dirs
          deps←les 0 loadProject¨dirs
          0∊⍴deps:⍵
          ⍵⊣⍵.nspath∘{
              e←('.'/⍨×≢⍵.main),⍵.main
              ⍺⍎⍵.projectSpace,'←',⍵.nspath,e
          }¨deps
      }

      loadSource←{
          top←⍺
          dir tgt←⍵
          pj←dir,'/package.json'
          ~⎕NEXISTS pj:0
          cfg←readCfg pj
     
          ns←cfg tgtSpace top tgt cfg.projectSpace
          9=⎕NC ns:cfg
          ~⎕NEXISTS dir,'/acreconfig.txt':. ⍝ missing acre config file?
          cmd←'acre.openproject ',dir,' ',ns
          cmd,←(~top)/' -track=off'
          cfg.nspath←⎕SE.UCMD cmd
          cfg
      }

      loadProject←{
          ⍺←1
          dir target←2↑(⊆⍵),0
          _←{
              path←⊃1 ⎕NPARTS ⍵,'/'
              ⎕SE.UCMD'cd ',path
          }⍣⍺⊢dir
          cfg←⍺ loadSource dir target
          cfg≡0:0
          _←'__apm'(cfg.nspath{⍺⍺⍎⍺,'←⍵'})cfg
          ⍺ loadDependencies cfg
      }

    camelToHyphen←{1↓⊃,/'-',¨lc⊂⍨1,1↓⍵≠lc←(819⌶)⍵}

      createProject←{
          dir ns←⍵
          path←⊃1 ⎕NPARTS dir,'/'
          ns←'#.'{⍵,⍨⍺/⍨⍺≢2↑⍵}ns
          cmd←'acre.createproject ',path,' ',ns
          nspath←⎕SE.UCMD cmd
          _←⎕SE.UCMD'cd ',path
          cfg←#.⎕NS''
          cfg.name←⊃⌽'.'(≠⊆⊢)ns
          cfg.version←'1.0.0'
          _←(json cfg)⎕NPUT path,'package.json'
          loadProject'.'
      }

:EndNamespace
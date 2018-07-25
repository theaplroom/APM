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
      c.Name←'LoadProject'
      c.Desc←'Load project into active workspace'
      c.Parse←'-target= -registry='
      r,←c
     
      r.Group←⊂NM
     
    ∇

    ∇ r←Run(Cmd Input);ns
      :Select Cmd
      :Case 'AddPackage'
          r←Input.registry add Input.Arguments Input.dev
      :Case 'FindPackage'
          r←Input.registry find⊃Input.Arguments
      :Case 'CreateProject'
          r←createProject 2↑Input.Arguments
      :Case 'LoadProject'
          r←loadProject(⊃Input.Arguments)Input.target
      :EndSelect
      r←⊃,/r,¨⎕UCS 13
    ∇

    ∇ r←level Help Cmd
      :Select Cmd
      :Case 'LoadProject'
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
          ⍺←~(1=≡⍵)∧0=10|⎕DR ⍵ ⍝ default to decode if simple string
          2::(7159+⍺)⌶⍵        ⍝ fallback for pre v16
          ⍺ ⎕JSON ⍵
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
          dir←⊃1 ⎕NPARTS ⍵.folder,⊃⍺⌽'../' 'node_modules/'
          ~⎕NEXISTS dir:⍵
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
          9=⎕NC ns:0
          ~⎕NEXISTS dir,'/acreconfig.txt':. ⍝ missing acre config file?
          cmd←'acre.openproject ',dir,' ',ns
          cmd,←(~top)/' -track=off'
          cfg.nspath←⎕SE.UCMD cmd
          cfg
      }

      loadProject←{
          ⍺←1
          dir target←2↑(⊆⍵),0
          cfg←⍺ loadSource dir target
          cfg≡0:0
          _←'__apm'(cfg.nspath{⍺⍺⍎⍺,'←⍵'})cfg
          ⍺ loadDependencies cfg
      }

    camelToHyphen←{1↓⊃,/'-',¨lc⊂⍨1,1↓⍵≠lc←(819⌶)⍵}

      createProject←{
          dir ns←⍵
          path←⊃1 ⎕NPARTS dir,'/'
          cmd←'acre.createproject ',path,' ',ns
          nspath←⎕SE.UCMD cmd
          _←⎕SE.UCMD'cd ',path
          cfg←#.⎕NS''
          cfg.name←camelToHyphen⊃⌽'.'(≠⊆⊢)ns
          cfg.version←'1.0.0'
          _←(json cfg)⎕NPUT path,'package.json'
          r←''
          r,←⊂'Project ',cfg.name,' created'
          r,←⊂'Current directory set to ',path
          r,←⊂'Install packages using ]APM.AddPackage'
          r
      }

:EndNamespace

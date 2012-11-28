###Copyright (c) 2012 hoo89 (hoo89@me.com) Licensed MIT###

#アガリ判定、待ち判定、役の判定・役の点計算などを行なっている部分

class MJ
  @jihai:(p)->
    p>26
  @kind:(p)->
    Math.floor(p/9)
  @number:(p)->
    Math.floor(p%9)
  @count_yaochu:(arr)->
    a=0
    for i in arr
      if i==0||i==8||i==9||i==17||i==18||i==26||26<i<34
        a++
    a
  @sangen:(p)->
    p==31||p==32||p==33
  @count_jihai:(arr)->
    a=0
    for i in arr
      if MJ.jihai(i) then a++
    a
  @green:(p)->
    p==19||p==20||p==21||p==23||p==25||p==32

class HaiCounter
  constructor:->
    @p=[]
    @nakis=[]
  count:(pai)->
    c=0
    for i in @p
      if i==pai then c+=1
    c

  heads:->
    a=[]
    for i in @p.uniq()
      if @count(i)>1 then a.push([i,i])

    a
        
  tartsu:->
    a=[]
    for p in @p
      for q in @p
        if !MJ.jihai(p)&&!MJ.jihai(q) && MJ.kind(p)==MJ.kind(q)
          if p<q && q-p<3 then a.push([p,q])
    a
    
  count_kinds:->
    @p.uniq().length

  has_koutsu:(hai)->
    @count(hai)>2

  koutsu:->
    a=[]
    for i in @p.uniq()
      if @has_koutsu(i)
        b=[i,i,i]
        b.kind=2
        a.push(b)
    a
  syuntsu:->
    a=[]
    for i in @p
      if MJ.jihai(i)|| i%9>6 then continue
      if @count(i+1)>0&&@count(i+2)
        b=[i,i+1,i+2]
        b.kind=1
        a.push(b)
    a

  add_naki:(m)->
    if m.length==4
      m.kan=true
    for i in m
      @p.splice(@p.indexOf(i),1)
    @nakis.push(m)
  #remove:(h)->
    #@p.splice(@p.indexOf(h),1)
    

count_hai=(arr,pai)->
    c=0
    for i in arr
      if i==pai then c+=1
    c

search_heads=(arr)->
  a=[]
  for i in arr.uniq()
    if count_hai(arr,i)>1
      b=[i,i]
      b.kind=0
      a.push(b)
  a
search_tartsu=(arr)->
    a=[]
    for i in arr
      for j in arr
        if !MJ.jihai(i)&& !MJ.jihai(j) && MJ.kind(i)==MJ.kind(j)
          if j>i && j-i < 3
            a.push([i,j])
    a
search_koutsu=(arr)->
  a=[]
  for i in arr.uniq()
    if count_hai(arr,i)>2
      b=[i,i,i]
      b.kind=2
      a.push(b)

  a

search_syuntsu=(arr)->
  a=[]
  for i in arr
    if MJ.jihai(i)|| i%9>6 then continue
    if count_hai(arr,i+1)>0&&count_hai(arr,i+2)>0
      b=[i,i+1,i+2]
      b.kind=1
      a.push(b)

  a
pop_mentsu=(arr1,arr2)->
  for i in arr2
    arr1.splice(arr1.indexOf(i),1)
  arr1
get_machi=(m)->
  if m[0]<m[1]
    a=m[0]
    b=m[1]
  else
    a=m[1]
    b=m[0]
  if b-a==1
    if a%9==0
      [b+1]
    else if b%9==8
      [a-1]
    else
      [a-1,b+1]
  else
    [a+1]

class Mentsu

class HaiChecker# extends MyPlayer
  constructor:(state)->
    #super
    @state=state
    @hais=new HaiCounter
    @agaris=[]
    @machis=[]
    @tehai=[]
    @last_hai

  can_pon:(h)->
    if @hais.count(h)>1
      return [h]
  can_chi:(h)->
    if MJ.jihai(h) then return false
    can_chi_hais=[]
    for i in @hais.tartsu()
      if MJ.kind(i[0])!=MJ.kind(h) then continue
      switch i[1]-i[0]
        when 1
          if MJ.number(i[0])==0
            if h-i[1]==1
              can_chi_hais.push(i[0],i[1])
          else if MJ.number(i[1])==8
            if i[0]-h==1
              can_chi_hais.push(i[0],i[1])
          else
            if h-i[1]==1||i[0]-h==1
              can_chi_hais.push(i[0],i[1])
        when 2
          if i[1]-h==1&&h-i[0]==1
            can_chi_hais.push(i[0],i[1])

    if can_chi_hais.length==0
      return false
    else
      return can_chi_hais


  push_tehai:(hai)->
    #super
    @hais.p.push(hai)
    @tehai.push(hai)
    @last_hai=hai
    #alert @tehai
  naki:(p,con)->
    @push_tehai(p)
    m=[p].concat(con)
    m.fooroh=true
    @hais.add_naki(m)
  ankan:(p,con)->
    @push_tehai(p)
    @hais.add_naki([p].concat(con))
  daiminkan:(p,con)->
    @push_tehai(p)
    m=[p].concat(con)
    m.fooroh=true
    @hais.add_naki(m)
  kakan:(p,con)->
    @push_tehai(p)
    #a=@checker.naki[@checker.naki.indexOf(con)]#赤入りとかのときに変える必要あるかも
    a.push(p)
    a.kan=true

  dahai:(h)->
    #super
    @hais.p.splice(h,1)
    @tehai.splice(h,1)
  remove_from_hais:(h)->
    @hais.p.splice(@hais.p.indexOf(h),1)
  remove:(h)->
    @hais.p.splice(@hais.p.indexOf(h),1)
    @tehai.splice(@tehai.indexOf(h),1)

  can_agari:->
    @agaris.length!=0
  get_agari:->
    max=0
    result=null
    for i in @agaris
      s=i.get_score()
      if max<s.score
        max=s.score
        result=s
    result
  get_actually_score:->
    a=@get_agari()
    #console.log "agari:",a
    if !a then throw "can't agari"
    score=a.score
    tscore=[0,0]
    oya=@state.is_oya()
    honba=@state.honba()
    if oya
      score=Math.ceil(score*1.5/100)*100
      tscore[0]=Math.ceil(score/300)*100+100*honba
      score+=300*honba
    else
      score=Math.ceil(score/100)*100
      tscore[0]=Math.ceil(score/400)*100+100*honba
      tscore[1]=Math.ceil(score/200)*100+100*honba
      score+=300*honba
    a.score=score
    a.scores=tscore
    a

  check_agari:->
    @mentsus=[]
    nakis=@hais.nakis
    @agaris.length=0
    @machis.length=0
    tmp_tehai=@hais.p.slice()
    #tmp_tehai.push(@last_hai)

    heads = @hais.heads()
    if heads.length==7
      @agaris.push(new Agari(@tehai,@last_hai,heads,@state))

    mentsu_kohos=@hais.koutsu().concat(@hais.syuntsu())

    if mentsu_kohos.length+nakis.length>=3
      hai_count={}
      for i in tmp_tehai
        if !hai_count[i]
          hai_count[i]=1
        else
          hai_count[i]++


      mentsu_koho_torios=[]

      generateCombinations(mentsu_kohos,3-nakis.length,(arr)->
        mentsu_koho_torios.push(arr)
      )

      count_back_hash={}
      for i,j of count_hash
        count_back_hash[i]=0
      
      for torio in mentsu_koho_torios
        loop_flag=true
        count_hash={}
        for i,j of hai_count
          count_hash[i]=j

        for m in torio
          for hai in m
            if count_hash[hai]==0
              loop_flag=false
              break
            else
              count_hash[hai]--
              #count_back_hash[hai]++

          if !loop_flag then break

        if loop_flag
          @mentsus.push({others:[]})
          @mentsus[@mentsus.length-1].torio=torio
          for i,j of count_hash
            for t in [0...j]
              @mentsus[@mentsus.length-1].others.push(parseInt(i))

      if @mentsus.length!=0
        for i in @mentsus
          heads=search_heads(i.others)
          #alert i.others
          switch heads.length
            when 0
              mens=search_syuntsu(i.others).concat(search_koutsu(i.others))
              for m in mens
                a=pop_mentsu(i.others.slice(),m)
                @machis.push([a[0],a[1]])
                if(a[1]) then @machis.push([a[1],a[0]])
            when 1
              pop_mentsu(i.others,heads[0])
              mens=search_syuntsu(i.others).concat(search_koutsu(i.others))
              if mens.length!=0
                i.torio.push(mens[0])
                ag=heads.concat(i.torio).concat(nakis)
                @agaris.push(new Agari(@tehai,@last_hai,ag,@state))
              else
                tartsu=search_tartsu(i.others)
                if tartsu.length!=0
                  for t in tartsu
                    for aaaa in get_machi(t)
                      #bbbb=t.slice().push(aaaa)
                      #alert bbbb
                      @machis.push([aaaa,pop_mentsu(i.others.slice(),t)[0]])
            when 2
              for h in heads
                tmp=i.others.slice()
                pop_mentsu(tmp,h)
                mens=search_syuntsu(tmp).concat(search_koutsu(tmp))
                if mens.length!=0
                  i.torio.push(mens[0])
                  ag=[h].concat(i.torio).concat(nakis)
                  console.log "agari",ag
                  @agaris.push(new Agari(@tehai,@last_hai,ag,@state))
                else
                  tartsu=search_tartsu(tmp)
                  if tartsu.length!=0
                    for t in tartsu
                      for aaaa in get_machi(t)
                        @machis.push([aaaa,pop_mentsu(tmp.slice(),t)[0]])
              tmp1=i.others.slice()
              pop_mentsu(tmp1,heads[0])
              pop_mentsu(tmp1,heads[1])
              @machis.push([heads[0][0],tmp1[0]])
              if(heads[1][0]) then @machis.push([heads[1][0],tmp1[0]])
    
    heads = @hais.heads()
    if heads.length==6
      tmp=tmp_tehai.slice()
      for i in heads
        pop_mentsu(tmp,i)
      @machis.push([tmp[0],tmp[1]])
      if(tmp[1]) then @machis.push([tmp[1],tmp[0]])
    @machis=@machis.uniq()
class DummyMJPlayerStates
  constructor:(a,b)->
  doras:->
    []
  yakuhai:(h)->
    false
  yakuhai:(p)->
    false
  jikaze:(p)->
    false
  bakaze:(p)->
    false
  get_yama_length:->
    return 30
  menzen:()->
    true
  tsumo:()->
    true
  reach:()->
    false
  reach_count:()->
    false


class Yaku
  constructor:(name,fan)->
    @name=name
    @fan=fan
  yakuman:->
    @fan>12

class YakuCheck
  tanyao:->
    if MJ.count_yaochu(@tehai)==0
      @yakus.push(new Yaku("タンヤオ",1))
      return true

  mentsumo:->
    if @menzen&&@tsumo
      @yakus.push(new Yaku("門前清自摸和",1))
      return true

  reach:->
    if @state.reach()
      if @state.is_doublereach()
        @yakus.push(new Yaku("ダブル立直",2))
      else
        @yakus.push(new Yaku("立直",1))
      if @state.is_ippatsu()
        @yakus.push(new Yaku("一発",1))
        
      return true
  houtei:->
    if @state.get_yama_length()==0
      if @tsumo
        @yakus.push(new Yaku("海底摸月",1))
      else
        @yakus.push(new Yaku("河底撈魚",1))
      return true
  pinhu:->
    for i in @mentsus[1..]
      if i.kind!=1 then return false
    if @state.yakuhai(@mentsus[0][0]) then return false
    if !@menzen then return false
    if !@get_machi()[3] then return false
    
    @yakus.push(new Yaku("平和",1))
    return true

  yakuhai:->
    for m in @mentsus
      if m.kind==2
        if @state.jikaze(m[0])&&@state.bakaze(m[0])
          @yakus.push(new Yaku("役牌",2))
        else if @state.yakuhai(m[0])
          @yakus.push(new Yaku("役牌",1))

  epei:->
    if @mentsus.uniq().length==4&&@menzen
      @yakus.push(new Yaku("一盃口",1))

  ryanpei:->
    if @mentsus.uniq().length==3&&@menzen
      @yakus.push(new Yaku("二盃口",3))

  toitoi:->
    for m in @mentsus[1..]
      if m.kind!=2 then return
    @yakus.push(new Yaku("対々和",2))

  sanan:->
    @anko_count=0
    for m in @mentsus
      if m.kind==2&&!m.fooroh then @anko_count++
      if @anko_count>3 then @yakus.push(new Yaku("三暗刻",2))

  doujyun:->
    flag=false
    syuntsu=[]
    for m in @mentsus
      if m.kind==1
        syuntsu.push(m)

    if syuntsu.length>=3
      for s in syuntsu
        colors=[]
        for t in syuntsu
          if MJ.number(s[0])==MJ.number(t[0])
            colors[MJ.kind(t[0])]=true
        if colors[0]&&colors[1]&&colors[2] then flag=true

      if flag
        if @menzen
          @yakus.push(new Yaku("三色同順",2))
        else
          @yakus.push(new Yaku("三色同順",1))

  doukou:->
    f=false
    koutsu=[]
    colors=[]
    for m in @mentsus
      if m.kind==2||m.kind==3
        koutsu.push(m)

    if koutsu.length>=3
      for s in koutsu
        colors=[]
        for t in koutsu
          if MJ.number(s[0])==MJ.number(t[0])
            colors[MJ.kind(t[0])]=true
      if colors[0]&&colors[1]&&colors[2]
        @yakus.push(new Yaku("三色同刻",2))

  ssangen:->
    if !MJ.sangen(@mentsus[0][0]) then return
    c=0
    for m in @mentsus
      if m.kind==2&&MJ.sangen(m[0])
        c++
    if c>2
      @yakus.push(new Yaku("小三元",2))
      #これだと白一色も大三元、小三元扱いになっちゃう…
      
  ittu:->
    syuntsu=[]
    for m in @mentsus
      if m.kind==1
        syuntsu.push(m)

    if syuntsu.length>=3
      a=[]
      for s in syuntsu
        a[s[0]]=1
      if a[0]&&a[3]&&a[6]||a[9]&&a[12]&&a[15]||a[18]&&a[21]&&a[24]
        if @menzen
          @yakus.push(new Yaku("一気通貫",2))
        else
          @yakus.push(new Yaku("一気通貫",1))

  chanta:->
    if MJ.count_yaochu(@tehai)==14
      @chinroh_flag=true
      @yakus.push(new Yaku("混老頭",2))
    else
      @chinroh_flag=false
      for m in @mentsus
        @jflag=true
        #@nflag=true
        if MJ.count_yaochu(m)==0 then return
        if MJ.count_jihai(m)>0 then @jflag=false
        #if m.fooroh then @nflag=false
      if @jflag
        if @menzen
          @yakus.push(new Yaku("純チャン",3))
        else
          @yakus.push(new Yaku("純チャン",2))
      else
        if @menzen
          @yaku.push(new Yaku("チャンタ",2))
        else
          @yaku.push(new Yaku("チャンタ",1))

  honitsu:->
    kind=null
    f=0
    for p in @tehai
      if MJ.jihai(p)
        f=1
      else
        if kind
          if kind!=MJ.kind(p)
            f=2
            break
        else
          kind=MJ.kind(p)
    if f==0
      if @menzen
        @yakus.push(new Yaku("清一色",6))
      else
        @yakus.push(new Yaku("清一色",5))
    else if f==1
      if @menzen
        @yakus.push(new Yaku("混一色",3))
      else
        @yakus.push(new Yaku("混一色",2))

  sankan:->
    c=0
    for m in @mentsus
      if m.kan then c++
    if c==3 then @yakus.push(new Yaku("三槓子",2))
  #役満
  suan:->
    c=0
    for m in @mentsus
      if m.kind==2&&!m.fooroh
        c++
    if c==4
      if @mentsus[0][0]==@last_hai
        @yakus.push(new Yaku("四暗刻単騎",26))
      else
        @yakus.push(new Yaku("四暗刻",13))
  dsangen:->
    c=0
    for m in @mentsus[1..]
      if MJ.sangen(m[0])
        c+=1
    if c>3
      @yakus.push(new Yaku("大三元",13))
  tooe:->
    for m in @mentsus
      if !MJ.jihai(m[0]) then return
    @yakus.push(new Yaku("字一色",13))
  green:->
    for p in @tehai
      if !MJ.green(p) then return
    @yakus.push(new Yaku("緑一色",13))
  chinroh:->
    if !@chinroh_flag then return
    for p in @tehai
      if MJ.jihai(p)
        return
    @yakus.push(new Yaku("清老頭",13))
  sushi:->
    dcount=0
    scount=0
    if 26<@mentsus[0][0]<31
      scount++
    for m in @mentsus[1..4]
      if 26<m[0]<31
        dcount++#例によって北一色とかには未対応
    if dcount>3
      @yakus.push(new Yaku("大四喜",13))
    else if dcount+scount>3
      @yakus.push(new Yaku("小四喜",13))
  sukan:->
    c=0
    for m in @mentsus
      if m.kan then c++
    if c==4 then @yakus.push(new Yaku("四槓子",13))
  tyuren:->

  kokushi:->
    if search_heads(@tehai).length ==1
      #手牌が全てヤオ九牌である
      if MJ.count_yaochu(@tehai)==14
                #手牌の種類を調べて、13種類あれば国士無双
        if @pais.uniq().length ==13    
          @yakus.push(new Yaku("国士無双（単騎待ち）",26))
        else if @tehai.uniq().length ==13
          @yakus.push(new Yaku("国士無双",13))
  tenho:->
  chiho:->

  check_yaku:->
    if !@checked
      @mentsumo()
      @reach()
      @tanyao()
      @pinhu_flag = @pinhu()
      @yakuhai()
      @epei()
      @ryanpei()
      @toitoi()
      @sanan()
      @suan()
      @sankan()
      @sukan()
      @doujyun()
      @doukou()
      @ittu()
      @honitsu()
      @chanta()
      @dsangen()
      @ssangen()
      @chinroh()
      @tooe()
      @sushi()
      @green()
      @tenho()
      @chiho()
      @checked=true

class Agari extends YakuCheck
  constructor:(pais,last_hai,mentsus,state)->#paisの仕様が違う
    @pais=pais
    @last_hai=last_hai
    @tehai=@pais.slice()
    @tehai.push(last_hai)
    @tsumo=state.tsumo()
    @mentsus=mentsus.slice()
 
    @yakus=[]
    @state=state

    @menzen=state.menzen()
    @yakuman=false
    @fu=20
    @pinhu_flag=false
    @tiitoi=false
    @checked=false
    @score=0

  get_yaku:->
    if @mentsus.length==1
      if @kokushi()
        @tenho()
        @chiho()

    else
      if @mentsus.length==7
        @yakus.push(new Yaku("七対子",2))#これは危険?
        @tiitoi=true

      @check_yaku()

    yakuman=@yakus.filter((y)->y.yakuman())
    if yakuman.length!=0
      @yakus=yakuman
      @mes="役満"
      @yakuman=true

    @yakus

  get_score:->
    if !@score then @calc_score()
    {fu:@fu,fan:@fan,score:@score,message:@mes,yakus:@yakus}

  calc_score:->
    @get_yaku()

    dora=0
    @fu=20
    for i in @state.doras()
      for j in @tehai
        if i==j then dora++#なんでcountがないし
    if dora>0
      @yakus.push(new Yaku("ドラ",dora))
    if @tiitoi
      @fu=25
    else
      if @menzen && !@tsumo
        @fu+=10
      else if !@menzen && !@tsumo && @pinhu_flag
        @fu+=10

      for m in @mentsus
        f=0
        if m.kind==2
          if m.kind==2&&!m.kan
            if m.fooroh
              f=2
            else
              f=4
          else if m.kan
            if m.fooroh
              f=8
            else
              f=16

          if MJ.count_yaochu(m)>=3
            f*=2
          @fu+=f

      if @state.yakuhai(@mentsus[0])
        @fu+=2
      machi=@get_machi()
      if machi[0]||machi[2]||machi[4]
        @fu+=2
      #alert @fu
      @fu=(Math.ceil(@fu/10))*10

    @fan=0
    for y in @yakus
      @fan+=y.fan

    @score=@fu*(Math.pow(2,@fan+2))

    @score=@score*4
    if @score>=8000
      if @yakuman
        @mes="役満"
        @score=(@fan/13)*32000
      else if @fan==5
        @mes="満貫"
        @score=8000
      else if @fan<8
        @mes="跳満"
        @score=12000
      else if @fan < 11
        @mes = "倍満"
        @score = 16000
      else if @fan < 13
        @mes = "三倍満"
        @score = 24000
      else if !@yakuman
        @mes = "数え役満"
        @score = 32000
    else
      @mes = @fu+"符"+@fan+"翻"

  get_machi:->
    machi=[]
    for m in @mentsus
      if @last_hai in m
        if !m.fooroh&&!m.kan
          if m.kind == 0
            machi[0]=true
          else if m.kind==2
            machi[1]=true
          else if m.kind ==1
            tartsu=m.filter((p)=>p!=@last_hai)
            if MJ.number(tartsu[0])+MJ.number(tartsu[1])==1||MJ.number(tartsu[0])+MJ.number(tartsu[1])==15
              machi[2]=true
            else if tartsu[0]-tartsu[1]==1||tartsu[0]-tartsu[1]==-1
              machi[3]=true
            else
              machi[4]=true
    machi
###
class Test1
  test:->
    player=new HaiChecker(new DummyMJPlayerStates)
    tyuren=[0,0,0,1,2,3,4,5,6,7,8,8,8,8]
    suanko=[0,0,0,5,5,5,9,9,9,12,12,12,16,16]
    pinhu=[0,0,0,1,2,6,7,8,18,19,20,21,22,23]
    a=[0,1,2,3,4,5,6,7,8,9,10,11,12,0]
    #a.sort((a,b)->
      #a-b)
    target=a

    for i in target
      player.push_tehai i
      player.tsumo i

    player.check_agari()
    
    mes=player.agaris[0].get_score().message
    score=player.agaris[0].get_score().score
    s=""
    for y in player.agaris[0].yakus
      s+=y.name+" "
    alert ""+target+"\n"+mes+" "+score+"点"+"\n"+s
    alert player.agaris[0].mentsus
  test2:->
    player=new HaiChecker(new DummyMJPlayerStates)
    tyuren=[0,0,0,1,2,3,4,5,6,7,8,8,8,16]
    suanko=[0,0,0,5,5,5,9,9,9,12,12,12,16,16]
    pinhu=[0,0,0,1,2,6,7,8,18,19,20,21,22,23]
    a=[0,1,2,3,4,5,6,7,8,9,10,11,12,0]
    #a.sort((a,b)->
      #a-b)
    target=tyuren

    for i in target
      player.push_tehai i
      player.tsumo i

    player.check_agari()
    
    machis=player.machis
    m=[]
    for i in machis
      m.push i[0]
    
    alert m.uniq().sort((a,b)->a-b)
    alert target
    

a=new Test1
a.test()
###


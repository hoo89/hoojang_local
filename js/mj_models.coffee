#ゲームの進行を担当する部分

class ModelBase
  constructor:->
    @listeners=[]
  add_listener:(a)->
    @listeners.push(a)
    a
  notify:(action)->
    for i in @listeners
      i.update(@,action)
  remove_listener:(a)->
    @listeners.splice(@listeners.indexOf(a),1)

class Stage extends ModelBase
  constructor:->
    super
    @statuslist={
      start_kyoku:0
      tsumo:1
      dahai:2
      other_player:3
      wait_for_response:4
    }
    @status=@statuslist.start_kyoku
    @action_que=[]
    @ActionSortIndex={hora:0,pon:1,kan:2,chi:3,none:4}
    
    @players = []
    for i in [0..3]
      if i == 0
        @players.push(new MyPlayer(i,i))
      else
        @players.push(new NPC(i,i))

    @kyoku=1
    @titya=0
    @oya=@titya
    @honba=0
    @bakaze=0
    @kyotaku=0

  update:->
    switch @status
      when 0
        a=@wait_for_start()
      when 1
        a=@wait_for_tsumo()
      when 2
        a=@wait_for_dahai()
      when 3
        a=@wait_for_other_player()

    if a
      @act a
      a
        
  wait_for_start:->
    @yama=new Yama
    @yama.shuffle()
    #@yama.tsumikomi [0,1,2,3,7,11,12,13,15,16,17,25,25]
    @wanpai=@yama.pop_wanpai()
    a={"type": "start_kyoku",
    "bakaze": @bakaze,
    "kyoku":@kyoku,
    "honba": @honba,
    "kyotaku": @kyotaku,
    "oya": @oya,
    "dora_marker" :@wanpai[0],
    "tehais":[[],[],[],[]]  
    }
    for i in [0...4]
      for j in [0...13]
        a.tehais[i].push @yama.shift()
    a

  wait_for_tsumo:->
    if @yama.length()==0
      type:"ryukyoku"
    else
      type:"tsumo",actor:@now_player,pai:@yama.shift()

  wait_for_dahai:->
    if @now_player.action
      @now_player.pop_action()

  wait_for_other_player:->
    for i in @players.filter((i)=> i!=@now_player)
      if i.action
        @action_que.push(i.pop_action())

    if @action_que.length<3
      return 
    #ロン>鳴き、ポン＞チー
    @action_que.sort((a,b)=>
      diff=@ActionSortIndex[a.type]-@ActionSortIndex[b.type]
      if diff!=0||a.type=="none" then diff
      else @now_player.get_distance(a.actor)-@now_player.get_distance(b.actor)
    )

    a=@action_que[0]

    if a.type!="hora"
      if @reached_player!=false
        p=@reached_player
        @reached_player=false
        return {type:"reach_accepted",actor:p}

    @action_que.length=0
    a

  act:(a)->
    switch a.type
      when "start_kyoku"
        @start(a)
        @status=@statuslist.tsumo
      when "tsumo"
        @turn++
        a.actor.tsumo(a)
        @status=@statuslist.dahai
      when "hora"
        a.actor.hora(a)
        @agari(a)
        @end_kyoku(a)
        @status=@statuslist.start_kyoku
        return
      when "reach"
        a.actor.reach_naki_count=@naki_count
        @reached_player=a.actor
        #@status=wait_for_response
        #serverからresponseがきたときにwait_for_dahai
      when "reach_accepted"
        a.actor.reach_accepted(a)
        @kyotaku++
        #点数変更
        a.actor.score-=1000
      when "dahai"
        a.actor.dahai(a)
        #他のPlayerに鳴き、ロン問い合わせ
        @players.filter((i)=> i!=a.actor).forEach((i)->
          i.ask(a))
        @status=@statuslist.other_player
      when "pon"
        #a.target.pop_kawa()
        a.actor.pon(a)
        @phase_set a.actor.number
        @status=@statuslist.dahai
      when "chi"
        #a.target.pop_kawa()
        a.actor.chi(a)
        @phase_set a.actor.number
        @status=@statuslist.dahai
      when "kan"
        if a.target==a.actor
          a.actor.kan(a)
        else
          #a.target.pop_kawa()
          a.actor.minkan(a)
          #カンStage処理
          @phase_set a.actor.number
          @status=@statuslist.dahai
      when "none"
        @next_phase()
        @status=@statuslist.tsumo
        #@update()
      when "ryukyoku"
        @end_kyoku(a)
        @status=@statuslist.start_kyoku
    if a.type=="pon"||a.type=="chi"||a.type=="kan"
      @naki_count++

    @notify a
    a

  start:(a)->
    @action_que.length=0      
    for i in @players
      i.set_kyoku()
      i.state=new MJState(i,@)
      i.checker=new HaiChecker(i.state)
    #@turn = 0
    @kan_count=0
    @wanpai=[]
    @doras=[]
    @uradoras=[]
    @reachbou=[0,0,0,0]
    @phase_set a.oya

    @naki_count=0

    @bakaze=a.bakaze
    @kyoku=a.kyoku
    @honba=a.honba
    @doras=[a.dora_marker]

    @reached_player=false

    for i,n in a.tehais
      for j in i
        @players[n].push_tehai(j)

  next_phase:()->    
    @phase_set(@phase+1)

  end_kyoku:(end_reason)->
    @end_reason_settigs||={
      0:["hora","nagasimangan"]
      1:["ryukyoku"]
    }
    
    switch end_reason.type
      when "hora"
        if end_reason.actor.is_oya()
          @honba++
        else
          @next_kyoku()
          
      when "ryukyoku"
        @notify type:"ryukyoku"
        #親がテンパイしてたかどうか調べといて分岐
        sum=0
        flag=false
        for i in @players
          if i.tenpai() then sum++
        ten=[[0,0],[3000,1000],[1500,1500],[1000,3000],[0,0]]
        for i in @players
          if i.tenpai()
            i.score+=ten[sum][0]
          else
            i.score-=ten[sum][1]
          if i.is_oya()
            flag=i.tenpai()
        if flag
          @honba++
        else
          @next_kyoku()
    @notify type:"end_kyoku"

  agari:(a)->
    if !a.hasOwnProperty("deltas")
      agari=a.actor.get_agari()
      

    if a.actor==a.target
      b=@players.filter((i)->i!=a.actor)
      for i in b
        if i.is_oya()
          i.score-=agari.scores[1]
          a.actor.score+=agari.scores[1]
        else
          i.score-=agari.scores[0]
          a.actor.score+=agari.scores[0]

        
    else
      a.target.score-=agari.score
      a.actor.score+=agari.score
      if @kyotaku!=0
        a.actor.score+=@kyotaku*1000
        @kyotaku=0
    @notify a

  phase_set:(a)->
    @phase=a%4
    @now_player=@players[@phase]

  get_titya:->
    @players[@titya]

  next_kyoku:->
    @honba=0
    @kyoku++
    if @kyoku>5
      @kyoku=1
      @bakaze++
      if @bakaze>4
        @players = []
        for i in [0..3]
          if i == 0
            @players.push(new MyPlayer(i,i))
          else
            @players.push(new NPC(i,i))

        @kyoku=1
        @titya=0
        @oya=@titya
        @honba=0
        @bakaze=0
        @kyotaku=0
        return

    for i in @players
      i.kaze=(i.kaze+1)%4
    @oya=(@oya+1)%4

class Yama
  constructor:->
    @a=[0..33].concat([0..33],[0..33],[0..33])
    #@count=0
    @count2=0
    
  shift:->
    #@a[@count++]
    @a.shift()
  unshift:->
    @a.unshift()
  get:()->
    @a
  shuffle:->
    @a=@a.shuffle()
  length:->
    @a.length
  pop_wanpai:->
    w=@a[124..131]
    @a.splice(124,14)
    w
  tsumikomi:(pais)->
    for i in pais
      @a.splice(@a.indexOf(i),1)
    for i in pais
      @a.unshift(i)

class MJState
  constructor:(player,stage)->
    @player=player
    @stage=stage
  doras:->
    if !@player.reach
      @stage.doras
    else
      @stage.doras.concat(@stage.uradoras)
  #ドラはここで数える
  #どれが赤ドラか、という情報はCheckerから参照できないため
  dora_count:->
    0
  #red_dora_count
  honba:->
    @stage.honba
  reachbou:->
    @stage.reachbou.reduce((x,y)->x+y)
  yakuhai:(h)->
    30<h<34||@jikaze(h)||@bakaze(h)
  jikaze:(h)->
    h==27+@player.kaze
  bakaze:(h)->
    h==27+@stage.bakaze
  get_yama_length:()->
    @stage.yama.length()
  menzen:()->
    @player.menzen
  tsumo:()->
    @player.tsumohai
  reach:()->
    @player.reach
  reach_count:()->
    @player.reach_count
  is_oya:()->
    @player.is_oya()
  is_doublereach:()->
    @stage.naki_count==0&&@player.kawa.length==0
  is_ippatsu:()->
    @player.reach_kawa_count==0&&@player.reach_naki_count==@stage.naki_count

class Player extends ModelBase
  constructor:(n,k)->
    super()
    @number=n
    @kaze=k
    @score=25000
    @set_kyoku()

  set_action:(a)->
    @action=a 
    @last_action=a
    if a then console.log a
  pop_action:->
    a=@action
    @set_action false
    a
  set_kyoku:->
    @set_action false
    @reach=false
    @reach_kawa_count=0
    @reach_naki_count=0
    @menzen=true
    @tsumohai=null
    @tehai=[]
    @kawa=[]
  push_tehai:(h) ->
    @tehai.push(h)
  push_kawa:(h)->
    @kawa.push(h)
  pop_kawa:->
    #@kawa.pop()
    #@notify type:"pop_kawa"
  tsumo:(a)->
    @push_tehai(a.pai)
    @tsumohai=a.pai
  dahai:(a)->
    @tehai.splice(@tehai.indexOf(a.pai),1)
    @kawa.push(a.pai)
    @tsumohai=false
    if @reach then @reach_kawa_count++
  reach_accepted:(a)->
    @reach=true
  ask:(a)->
    @target_pai=a.pai
    @target_player=a.actor
  pon:(a)->
    @menzen=false
  chi:(a)->
    @menzen=false
  hora:(a)->
  kan:(a)->
  daiminkan:(a)->
    @menzen=false
  kakan:(a)->
  is_oya:()->
    @kaze==0
  get_agari:()->
    null
  can_agari:()->
    false
  can_ron:(h)->
    false
  can_pon:(h)->
    false
  can_chi:(h)->
    false
  can_kan:(h)->
    false
  can_reach:()->
    false
  tenpai:->
    false
  get_distance:(player)->
    #player_aから見て上家が1,対面が2,下家が3
    a=@number-player.number
    if a>0
      return a
    else
      return a+4
    return 0

class Player1 extends Player
  push_tehai:(pai)->
    super
    @checker.push_tehai(pai)
  tsumo:(a)->
    @push_tehai(a.pai)
    @tsumohai=a.pai
    @checker.check_agari()#重いようならNPCのこれは切る
  dahai:(a)->
    super
    @checker.remove(a.pai)
  get_agari:()->
    @checker.get_actually_score()
  can_agari:()->
    @checker.can_agari()
  can_ron:()->
    @checker.check_agari()
    if @target_pai in @checker.machis.map((i)->i[0])
      return @checker.machis.map((i)->i[1])
  can_pon:()->
    if @checker.can_pon(@target_pai)&&!@reach
      return [@target_pai]
  can_chi:()->
    if @get_distance(@target_player)==1&&!@reach #これでいいのか微妙
      @checker.can_chi(@target_pai)
  can_reach:()->
    if @checker.machis.length!=0&&@menzen&&!@reach
      return @checker.machis.map((i)->i[1])
  hora:(a)->
    super
    if a.target!=@
      @checker.push_tehai(a.pai)
      @checker.check_agari()
  tenpai:->
    @checker.machis.length!=0
  pon:(a)->
    super
    @checker.naki(a.pai,a.consumed)
  chi:(a)->
    super
    @checker.naki(a.pai,a.consumed)
  kan:(a)->
    super
    @checker.kan(a.pai,a.consumed)
  daiminkan:(a)->
    super
    @checker.daiminkan(a.pai,a.consumed)

class MyPlayer extends Player1
  set_action:(a)->
    super
    if a then @notify type:"selected",action:a,actor:@

class NPC extends Player1
  ask:(a)->
    super
    @set_action type:"none",actor:@
  tsumo:(a)->
    super
    @set_action type: "dahai",pai: a.pai,index: 13,actor:@
    
class Plain extends Player

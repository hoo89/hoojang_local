###Copyright (c) 2012 hoo89 (hoo89@me.com) Licensed MIT###

#ゲームの表示を主に担当する部分 MVCのVとC
#未完成につき注意

enchant()

GAME_WIDTH=640
GAME_HEIGHT=640

class MyEntity extends Label
  element :() ->
    @_element

class MyGame extends Game
  constructor :(stage) ->
    super GAME_WIDTH, GAME_HEIGHT
    MyGame.game = @
    @fps = 30
    @preload "resource/sou5red.bmp"
    @pushScene(@screen=new MahjongScreen())
    @onload = =>
      @a=stage
      @stage_view=new StageViewComponents(@a)

      @screen.addEventListener "enterframe",=>
        @a.update()

      #@foo=new MyEntity
      #@foo.text="ロン"
      #enchant.Game.instance.screen.addChild(@foo)
      #$(@foo.element()).button()

    @start()

class ViewBase
  update:(sub,a)->
  #constructor:(model)->
    #@model=model
    #@model.add_listener(@)
  #destroy:->
    #@model.remove_listener(@)

class ModelDebug
  log:(n,a)->
    m="player:"+n+" "+a.type+" "
    for i,j of a
      m+=i+":"+j+" "
    console.log m

class StageViewComponents extends ViewBase
  constructor:(stage)->

    @stage=stage
    @stage.add_listener(@)
    @pviews=[]
    for i in [0..3]
      if i==0
        @pviews.push(new MyPlayerView(stage.players[i],i))
      else
        @pviews.push(new NPCPlayerView(stage.players[i],i))
    @info=new StageInfoView(stage)
    @mdebug=new ModelDebug

  update:(sub,a)->
    switch a.type
      when "start_kyoku"
        @info.update(sub,a)
        for i in @pviews
          if i[a.type]
            i[a.type](a)
      when "hora","ryukyoku"
        @info.update(sub,a)
      when "tsumo","reach","reach_accepted"
        n=a.actor.number
        if @pviews[n][a.type]
          @pviews[n][a.type](a)
      when "dahai"
        n=a.actor.number
        if @pviews[n][a.type]
          @pviews[n][a.type](a)
        if a.actor.number!=0
          @pviews[0].wait_for_naki(a)
      when "pon","chi","kan"
        n=a.actor.number
        if @pviews[n][a.type]
          @pviews[n][a.type](a)
    if a.hasOwnProperty("actor")
      @mdebug.log(a.actor.number,a)



class PlayerView
  constructor:(@model,n)->
  start_kyoku:(a)->
    @tehai.clear()
    @kawa.clear()
    for i in @model.tehai
      @tehai.push i
  tsumo:(a)->
    @tehai.push(a.pai)
  dahai:(a)->
    if a.hasOwnProperty("index")
      @tehai.delete_at(a.index)
    else
      @tehai.remove(a.pai)
    @kawa.push(a.pai)
    @tehai.sort()

  pop_kawa:(a)->
    @kawa.pop()
  pon:(a)->
    @add_naki(a)
  chi:(a)->
    @add_naki(a)
  add_naki:(a)->
    for i in a.consumed
      @tehai.remove(i)
    n=@model.get_distance(@model.target_player)
    @tehai.add_naki(a.pai,a.consumed,n)
    @tehai.sort()

class MyPlayerView extends PlayerView
  constructor:(@model,n)->
    super
    @tehai=new PlayerTehai("tehai_"+n)
    @kawa=new Kawa("kawa_"+n)
    @status="none"
    #@tehai.unlocked_hai=[]
    @tehai.addEventListener "mjPaiTouch",(e)=>
      switch @status
        when "none"
          @model.set_action type: "dahai",pai: e.pai.val,index: e.pai.index,actor: @model
        when "pon","chi","kan"
        　　#入力チェック（仮）
          if @tehai.select_hais.length!=@tehai.select_hai_max
            return
          @tehai.select_hai_max=1
          c=@tehai.select_hais.map((i)->i.val)
          @model.set_action type: @status,pai: @model.target_pai,consumed:c,actor: @model,target: @model.target_player
          @buttons.hide_all()
          @tehai.unlock()
          @status="none"

  set_buttons:->
    if @buttons
      @buttons.hide_all()
      return
    @buttons=new MJRonButtons
    a={
      tsumo:=>
        @model.set_action {
            type:"hora"
            actor:@model
            pai:@model.tsumohai
            target:@model
        }
      ron:=>
        @model.set_action {
          type:"hora"
          actor:@model
          pai:@model.target_pai
          target:@model.target_player
        }
      cancel:=>
        @model.set_action {
          type:"none"
          actor:@model
        }
        @buttons.hide_all()
        @status="none"
      pon:=>
        @tehai.select_hai_max=2
        @status="pon"
        #@tehai.lock=false
        p=@model.can_pon()
        for i in @tehai.pais
          if i.val in p
            i.lock=false
          else
            i.lock=true

      chi:=>
        @tehai.select_hai_max=2
        @status="chi"
        #@tehai.lock=false
        p=@model.can_chi()
        for i in @tehai.pais
          if i.val in p
            i.lock=false
          else
            i.lock=true
      reach:=>
        @model.set_action {
          type:"reach"
          actor:@model
        }
        p=@model.can_reach()
        for i in @tehai.pais
          if i.val in p
            i.lock=false
          else
            i.lock=true
    }
    for i,j of a
      if @buttons.hasOwnProperty(i)
        @buttons[i].ontouchstart = j

    @buttons.hide_all()

  start_kyoku:(a)->
    super
    #@tehai.lock=true
    @tehai.lock()
    #@tehai.reach=false
    @reach_flag=false
    @tehai.sort()
    @set_buttons()
  reach_accepted:()->
    @tehai.reach=true

  tsumo:(a)->
    @tehai.push(a.pai)
    #@tehai.lock=false
    if !@model.reach
      #alert "a"
      @tehai.unlock()
    if @model.can_agari()
      @buttons.tsumo.visible=true
    if @model.can_reach()
      @buttons.reach.visible=true
  dahai:(a)->
    #@tehai.lock=true
    @tehai.lock()
    @buttons.hide_all()
    if a.hasOwnProperty("index")
      @tehai.delete_at(a.index)
    else
      @tehai.remove(a.pai)
    @kawa.push(a.pai)
    @tehai.sort()
    if @reach_flag 
      @reach()
  wait_for_naki:(a)->
    f=false
    if @model.can_pon()
      @buttons.pon.visible=f=true
    if @model.can_chi()
      @buttons.chi.visible=f=true
    if @model.can_kan()
      @buttons.kan.visible=f=true
    if @model.can_ron()
      @buttons.ron.visible=f=true
    if !f 
      @model.set_action type:"none",actor:@model
      return
    @buttons.cancel.visible=true

class NPCPlayerView extends PlayerView
  constructor:(@model,n)->
    super
    @tehai=new NPCTehai("tehai_"+n)
    @kawa=new Kawa("kawa_"+n)

class AgariMessage
  constructor:(action,agari,stage)->
    if !agari 
      alert "フリテン"
      return
    y=""
    for i in agari.yakus
      y+=i.name+" "
    alert y+"\n"+agari.message+" "+agari.score+"点"

class StageInfoView
  constructor:(@stage)->
    #@stage.add_listener(@)
    @players=@stage.players
    @kyoku_label=new Label("")
    @kyoku_label.layout_id="kyoku_label"
    @scores=[]
    for i,j in @players
      @scores.push(new Label(""))
      @scores[j].layout_id=@scores[j].id="score_"+j
    @doras=[]
    @kyoku_names=["東","南","西","北"]
    enchant.Game.instance.screen.addChild(@kyoku_label)
    for i in @scores
      enchant.Game.instance.screen.addChild(i)

  update:(subject,action)->
    switch action.type
      when "start_kyoku"
        @kyoku_label.text=@kyoku_names[Math.floor((@stage.kyoku-1)/4)]+((@stage.kyoku-1)%4+1)+"局 "+@stage.honba+"本場"
        for i in [0...4]
          @scores[i].text=""+@players[i].score

      when "hora"
        a=action.actor
        agari=a.get_agari()

        new AgariMessage(action,agari,@)
  add_dora:(p)->
    dora.push(p)

class MJPlayerScores extends ViewBase
  constructor:(model)->

  update:(sub,a)->
    switch a.type
      when "start_kyoku","reach_accepted"
        @updateLabel()
  #updateLabel:->
    #score.txt=@model.score

class MJRonButtons
  imageSizeX:30
  imageSizeY:30
  constructor:->
    b={reach:"立直",pon:"ポン",chi:"チー",kan:"カン",ron:"ロン",cancel:"✕",tsumo:"ツモ"}
    @buttons=[]
    margin=50
    x=0
    for i,j of b
      @[i]=new Button(j)
      @[i].layout_id="button"
      @[i].moveBy(x,0)
      x+=margin
      @[i].visible=false
      enchant.Game.instance.screen.addChild(@[i])
      @buttons.push(@[i])
      
  hide_all:->
    for i in @buttons
      i.visible=false
    
class PaiSprite extends Sprite
  imageSizeX:30
  imageSizeY:52

  constructor: (val) ->
    super @imageSizeX,@imageSizeY

    @val=val
    @image = MyGame.game.assets["resource/sou5red.bmp"]
    @frame = val

class DraggablePai extends PaiSprite
  constructor:(val)->
    super
    @addEventListener(enchant.Event.TOUCH_START,(e) =>
      @touch_start(e)
    )
    @addEventListener(enchant.Event.TOUCH_MOVE,(e) =>
      @touch_move(e)
    )
    @addEventListener(enchant.Event.TOUCH_END,(e) =>
      @touch_end(e)
    )
  onenterframe:->
    if @lock
      @opacity=0.5
    else
      @opacity=1

  touch_start:(e)->
    @sabunX = e.x - @x
    @sabunY = e.y - @y
    @originX = @x
    @originY = @y

  touch_move:(e)->
    if @unlocked()
      @moveTo(e.x - @sabunX,e.y - @sabunY)

    if @selected()
      @opacity=0.6

    if @distance()>10000
      @touched=false
      if !@selected() then @select()

    else if !@touched
      @deselect()
      @opacity=1

  touch_end:(e)->
    @x=@originX
    @y=@originY
    if @unlocked()&&@selected()
      @parentNode.dispatchEvent(type: "mjPaiTouch",pai: this,pais: @parentNode.select_hais)
      @deselect()
    else
      @opacity=1
      if @unlocked()
        @select()
        @touched=true
  distance:->
    Math.pow(@x-@originX,2)+Math.pow(@y-@originY,2)
  select:->
    @parentNode.select(@)
  selected:->
    @parentNode.selected(@)
  deselect:->
    @parentNode.deselect()
  unlocked:->
    #!@parentNode.lock&&(!@parentNode.reach||@index==13)
    #!@parentNode.lock
    !@lock

class PaiHolder extends CanvasGroup
  imageSizeX: 30
  imageSizeY: 52
  maxCol:100

  pais: []

  constructor:(layout_id) ->
    super()
    @layout_id=layout_id
    
  push: (val) ->
    @addChild(pai=new PaiSprite(val))
    @pais.push(pai)
    pai.moveTo(@imageSizeX*((@pais.length-1)%@maxCol),@imageSizeY*Math.floor((@pais.length-1)/@maxCol))
    pai.index=@pais.length-1

  delete_at: (pos) ->
    return if pos==-1
    @removeChild(a=@pais[pos])
    @pais.splice(pos,1)
    a

  pop:()->
    @delete_at(@pais.length-1)
  clear:()->
    while @pais.length
      @pop()
  remove: (pai) ->
    @delete_at(@pais.map((i)->i.val).indexOf(pai))

class Tehai extends PaiHolder
  imageSizeX: 30
  imageSizeY: 52
  constructor:(layout_id)->
    super
    @nakilist=[]
    @hais=[]
    enchant.Game.instance.screen.addChild(this)

  push: (val) ->
    @addChild(pai=new DraggablePai(val))
    @pais.push(pai)
    pai.moveTo(@imageSizeX*((@pais.length-1)%@maxCol),@imageSizeY*Math.floor((@pais.length-1)/@maxCol))
    pai.index=@pais.length-1

  sort: ->
    @pais.sort( (a,b)-> if a.val!=b.val then a.val - b.val
    else a.index - b.index )
    for i in [0...@pais.length]
      @pais[i].tl.moveTo(@imageSizeX*i,0,5)
      @pais[i].index=i

  clear:->
    super
    for i in @nakilist
      for j in i
        @removeChild(j)
    @nakilist=[]

  add_naki:(h,hais,location)->
    x=400-@nakilist.length*120
    m=[]
    for i in [0...hais.length+1]
      if location==i+1
        @addChild(pai=new PaiSprite(h))
        pai.rotate(270)
        pai.moveTo(x+10,10)
        x+=@imageSizeY
        m.push(pai)
      else
        @addChild(pai=new PaiSprite(hais.shift()))
        pai.moveTo(x,0)
        x+=@imageSizeX
        m.push(pai)
    @nakilist.push(m)

class PlayerTehai extends Tehai
  imageSizeX: 30
  imageSizeY: 52
  line_width:4
  constructor:(layout) ->
    #@pais=[]
    #@lock=true
    @select_hais=[]
    @select_hai_max=1
    @wakus=[]
    super
    #enchant.Game.instance.screen.addChild(this)
    @set_waku()

  set_waku:->
    for i in [0...4]
      @wakus.push(w=new Waku)
      @addChild(w)

  select:(p)->
    #alert "a"
    if @select_hais.length>=@select_hai_max
      @deselect(@select_hais[0])
    @select_hais.push(p)
    p.addEventListener(enchant.Event.TOUCH_MOVE,a=(e) =>
      for i,n in @select_hais
        @wakus[n].visible=true
        @wakus[n].x=i.x-15
        @wakus[n].y=i.y-15
    )
    n=@select_hais.length-1
    @wakus[n].x=p.x-15
    @wakus[n].y=p.y-15
    @wakus[n].visible=true
    p.waku_listener=a

  deselect:()->
    for p,n in @select_hais
      @wakus[n].visible=false
      p.removeEventListener(enchant.Event.TOUCH_MOVE,p.waku_listener)
    @select_hais.length=0

  selected:(p)->
    p in @select_hais

  lock:->
    for i in @pais
      i.lock=true
  unlock:->
    for i in @pais
      i.lock=false

class NPCTehai extends Tehai
  constructor:(layout)->
    super
    @pais=[]
    #for i in [0..12]
      #@push(new Pai(34))
    #enchant.Game.instance.screen.addChild(this)
  remove:(a)->
    @delete_at(Math.floor(Math.random()*@pais.length))
  push: (val) ->
    @addChild(pai=new PaiSprite(34))
    @pais.push(pai)
    pai.moveTo(@imageSizeX*((@pais.length-1)%@maxCol),@imageSizeY*Math.floor((@pais.length-1)/@maxCol))
    pai.index=@pais.length-1

class Waku extends Sprite
  imageSizeX: 30
  imageSizeY: 52
  line_width: 4
  constructor:->
    super 100,100
    @visible=false
    @image=new Surface(100,100)
    @image.context.shadowBlur = 20
    @image.context.shadowColor="rgb(255,128,0)"
    @image.context.strokeStyle="rgb(255,128,0)"
    @image.context.lineWidth=@line_width
    @image.context.strokeRect(@line_width+10,@line_width+10,@imageSizeX+@line_width/2,@imageSizeY+@line_width/2)
    @opacity=0.6

class Kawa extends PaiHolder
  imageSizeX: 30*0.8
  imageSizeY: 52*0.8

  constructor:(layout)->
    super
    enchant.Game.instance.screen.addChild(this)
    @pais=[]
    @maxCol=6

  push:(val)->
    @addChild(pai=new PaiSprite(val))
    pai.scale(0.8,0.8)#設計的に…
    @pais.push(pai)
    pai.moveTo(@imageSizeX*((@pais.length-1)%@maxCol),@imageSizeY*Math.floor((@pais.length-1)/@maxCol))
    pai.index=@pais.length-1

#window.onload = ->
  #new MyGame(new Stage)

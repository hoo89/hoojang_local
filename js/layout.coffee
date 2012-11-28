GAME_WIDTH=640
GAME_HEIGHT=640
#imageSizeX: 30
#imageSizeY: 52
MJ_LAYOUTS={
  tehai_0:{rotation:0,x:110,y:578},
  tehai_1:{rotation:3,x:578,y:530},
  tehai_2:{rotation:2,x:530,y:62},
  tehai_3:{rotation:1,x:62,y:110},
  kawa_0:{rotation:0,x:248,y:392},
  kawa_1:{rotation:3,x:392,y:392},
  kawa_2:{rotation:2,x:392,y:248},
  kawa_3:{rotation:1,x:248,y:248},
  button:{rotation:0,x:200,y:530},
  kyoku_label:{rotation:0,x:280,y:370,fontsize:20},
  score_0:{x:300,y:360},
  score_1:{x:220,y:190},
  score_2:{x:40,y:270},
  score_3:{x:110,y:460},

}
class MahjongScreen extends Scene
  addChild:(n)->
    if MJ_LAYOUTS[n.layout_id]
      n.rotation=MJ_LAYOUTS[n.layout_id].rotation*90
      if MJ_LAYOUTS[n.layout_id].fontsize
        #alert "a"
        n.font=MJ_LAYOUTS[n.layout_id].fontsize+"px メイリオ"
        #n.color = '#f00'
      switch MJ_LAYOUTS[n.layout_id].rotation
        when 1
          n.moveTo -GAME_WIDTH,0
        when 2
          n.moveTo -GAME_WIDTH,-GAME_HEIGHT
        when 3
          n.moveTo 0,-GAME_HEIGHT
      n.moveBy MJ_LAYOUTS[n.layout_id].x,MJ_LAYOUTS[n.layout_id].y
    super

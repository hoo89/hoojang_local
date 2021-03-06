// Generated by CoffeeScript 1.4.0
/*Copyright (c) 2012 hoo89 (hoo89@me.com) Licensed MIT
*/

var AgariMessage, DraggablePai, GAME_HEIGHT, GAME_WIDTH, Kawa, MJPlayerScores, MJRonButtons, ModelDebug, MyEntity, MyGame, MyPlayerView, NPCPlayerView, NPCTehai, PaiHolder, PaiSprite, PlayerTehai, PlayerView, StageInfoView, StageViewComponents, Tehai, ViewBase, Waku,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

enchant();

GAME_WIDTH = 640;

GAME_HEIGHT = 640;

MyEntity = (function(_super) {

  __extends(MyEntity, _super);

  function MyEntity() {
    return MyEntity.__super__.constructor.apply(this, arguments);
  }

  MyEntity.prototype.element = function() {
    return this._element;
  };

  return MyEntity;

})(Label);

MyGame = (function(_super) {

  __extends(MyGame, _super);

  function MyGame(stage) {
    var _this = this;
    MyGame.__super__.constructor.call(this, GAME_WIDTH, GAME_HEIGHT);
    MyGame.game = this;
    this.fps = 30;
    this.preload("resource/sou5red.bmp");
    this.pushScene(this.screen = new MahjongScreen());
    this.onload = function() {
      _this.a = stage;
      _this.stage_view = new StageViewComponents(_this.a);
      return _this.screen.addEventListener("enterframe", function() {
        return _this.a.update();
      });
    };
    this.start();
  }

  return MyGame;

})(Game);

ViewBase = (function() {

  function ViewBase() {}

  ViewBase.prototype.update = function(sub, a) {};

  return ViewBase;

})();

ModelDebug = (function() {

  function ModelDebug() {}

  ModelDebug.prototype.log = function(n, a) {
    var i, j, m;
    m = "player:" + n + " " + a.type + " ";
    for (i in a) {
      j = a[i];
      m += i + ":" + j + " ";
    }
    return console.log(m);
  };

  return ModelDebug;

})();

StageViewComponents = (function(_super) {

  __extends(StageViewComponents, _super);

  function StageViewComponents(stage) {
    var i, _i;
    this.stage = stage;
    this.stage.add_listener(this);
    this.pviews = [];
    for (i = _i = 0; _i <= 3; i = ++_i) {
      if (i === 0) {
        this.pviews.push(new MyPlayerView(stage.players[i], i));
      } else {
        this.pviews.push(new NPCPlayerView(stage.players[i], i));
      }
    }
    this.info = new StageInfoView(stage);
    this.mdebug = new ModelDebug;
  }

  StageViewComponents.prototype.update = function(sub, a) {
    var i, n, _i, _len, _ref;
    switch (a.type) {
      case "start_kyoku":
        this.info.update(sub, a);
        _ref = this.pviews;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (i[a.type]) {
            i[a.type](a);
          }
        }
        break;
      case "hora":
      case "ryukyoku":
        this.info.update(sub, a);
        break;
      case "tsumo":
      case "reach":
      case "reach_accepted":
        n = a.actor.number;
        if (this.pviews[n][a.type]) {
          this.pviews[n][a.type](a);
        }
        break;
      case "dahai":
        n = a.actor.number;
        if (this.pviews[n][a.type]) {
          this.pviews[n][a.type](a);
        }
        if (a.actor.number !== 0) {
          this.pviews[0].wait_for_naki(a);
        }
        break;
      case "pon":
      case "chi":
      case "kan":
        n = a.actor.number;
        if (this.pviews[n][a.type]) {
          this.pviews[n][a.type](a);
        }
    }
    if (a.hasOwnProperty("actor")) {
      return this.mdebug.log(a.actor.number, a);
    }
  };

  return StageViewComponents;

})(ViewBase);

PlayerView = (function() {

  function PlayerView(model, n) {
    this.model = model;
  }

  PlayerView.prototype.start_kyoku = function(a) {
    var i, _i, _len, _ref, _results;
    this.tehai.clear();
    this.kawa.clear();
    _ref = this.model.tehai;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push(this.tehai.push(i));
    }
    return _results;
  };

  PlayerView.prototype.tsumo = function(a) {
    return this.tehai.push(a.pai);
  };

  PlayerView.prototype.dahai = function(a) {
    if (a.hasOwnProperty("index")) {
      this.tehai.delete_at(a.index);
    } else {
      this.tehai.remove(a.pai);
    }
    this.kawa.push(a.pai);
    return this.tehai.sort();
  };

  PlayerView.prototype.pop_kawa = function(a) {
    return this.kawa.pop();
  };

  PlayerView.prototype.pon = function(a) {
    return this.add_naki(a);
  };

  PlayerView.prototype.chi = function(a) {
    return this.add_naki(a);
  };

  PlayerView.prototype.add_naki = function(a) {
    var i, n, _i, _len, _ref;
    _ref = a.consumed;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      this.tehai.remove(i);
    }
    n = this.model.get_distance(this.model.target_player);
    this.tehai.add_naki(a.pai, a.consumed, n);
    return this.tehai.sort();
  };

  return PlayerView;

})();

MyPlayerView = (function(_super) {

  __extends(MyPlayerView, _super);

  function MyPlayerView(model, n) {
    var _this = this;
    this.model = model;
    MyPlayerView.__super__.constructor.apply(this, arguments);
    this.tehai = new PlayerTehai("tehai_" + n);
    this.kawa = new Kawa("kawa_" + n);
    this.status = "none";
    this.tehai.addEventListener("mjPaiTouch", function(e) {
      var c;
      switch (_this.status) {
        case "none":
          return _this.model.set_action({
            type: "dahai",
            pai: e.pai.val,
            index: e.pai.index,
            actor: _this.model
          });
        case "pon":
        case "chi":
        case "kan":
          if (_this.tehai.select_hais.length !== _this.tehai.select_hai_max) {
            return;
          }
          _this.tehai.select_hai_max = 1;
          c = _this.tehai.select_hais.map(function(i) {
            return i.val;
          });
          _this.model.set_action({
            type: _this.status,
            pai: _this.model.target_pai,
            consumed: c,
            actor: _this.model,
            target: _this.model.target_player
          });
          _this.buttons.hide_all();
          _this.tehai.unlock();
          return _this.status = "none";
      }
    });
  }

  MyPlayerView.prototype.set_buttons = function() {
    var a, i, j,
      _this = this;
    if (this.buttons) {
      this.buttons.hide_all();
      return;
    }
    this.buttons = new MJRonButtons;
    a = {
      tsumo: function() {
        return _this.model.set_action({
          type: "hora",
          actor: _this.model,
          pai: _this.model.tsumohai,
          target: _this.model
        });
      },
      ron: function() {
        return _this.model.set_action({
          type: "hora",
          actor: _this.model,
          pai: _this.model.target_pai,
          target: _this.model.target_player
        });
      },
      cancel: function() {
        _this.model.set_action({
          type: "none",
          actor: _this.model
        });
        _this.buttons.hide_all();
        return _this.status = "none";
      },
      pon: function() {
        var i, p, _i, _len, _ref, _ref1, _results;
        _this.tehai.select_hai_max = 2;
        _this.status = "pon";
        p = _this.model.can_pon();
        _ref = _this.tehai.pais;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (_ref1 = i.val, __indexOf.call(p, _ref1) >= 0) {
            _results.push(i.lock = false);
          } else {
            _results.push(i.lock = true);
          }
        }
        return _results;
      },
      chi: function() {
        var i, p, _i, _len, _ref, _ref1, _results;
        _this.tehai.select_hai_max = 2;
        _this.status = "chi";
        p = _this.model.can_chi();
        _ref = _this.tehai.pais;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (_ref1 = i.val, __indexOf.call(p, _ref1) >= 0) {
            _results.push(i.lock = false);
          } else {
            _results.push(i.lock = true);
          }
        }
        return _results;
      },
      reach: function() {
        var i, p, _i, _len, _ref, _ref1, _results;
        _this.model.set_action({
          type: "reach",
          actor: _this.model
        });
        p = _this.model.can_reach();
        _ref = _this.tehai.pais;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (_ref1 = i.val, __indexOf.call(p, _ref1) >= 0) {
            _results.push(i.lock = false);
          } else {
            _results.push(i.lock = true);
          }
        }
        return _results;
      }
    };
    for (i in a) {
      j = a[i];
      if (this.buttons.hasOwnProperty(i)) {
        this.buttons[i].ontouchstart = j;
      }
    }
    return this.buttons.hide_all();
  };

  MyPlayerView.prototype.start_kyoku = function(a) {
    MyPlayerView.__super__.start_kyoku.apply(this, arguments);
    this.tehai.lock();
    this.reach_flag = false;
    this.tehai.sort();
    return this.set_buttons();
  };

  MyPlayerView.prototype.reach_accepted = function() {
    return this.tehai.reach = true;
  };

  MyPlayerView.prototype.tsumo = function(a) {
    this.tehai.push(a.pai);
    if (!this.model.reach) {
      this.tehai.unlock();
    }
    if (this.model.can_agari()) {
      this.buttons.tsumo.visible = true;
    }
    if (this.model.can_reach()) {
      return this.buttons.reach.visible = true;
    }
  };

  MyPlayerView.prototype.dahai = function(a) {
    this.tehai.lock();
    this.buttons.hide_all();
    if (a.hasOwnProperty("index")) {
      this.tehai.delete_at(a.index);
    } else {
      this.tehai.remove(a.pai);
    }
    this.kawa.push(a.pai);
    this.tehai.sort();
    if (this.reach_flag) {
      return this.reach();
    }
  };

  MyPlayerView.prototype.wait_for_naki = function(a) {
    var f;
    f = false;
    if (this.model.can_pon()) {
      this.buttons.pon.visible = f = true;
    }
    if (this.model.can_chi()) {
      this.buttons.chi.visible = f = true;
    }
    if (this.model.can_kan()) {
      this.buttons.kan.visible = f = true;
    }
    if (this.model.can_ron()) {
      this.buttons.ron.visible = f = true;
    }
    if (!f) {
      this.model.set_action({
        type: "none",
        actor: this.model
      });
      return;
    }
    return this.buttons.cancel.visible = true;
  };

  return MyPlayerView;

})(PlayerView);

NPCPlayerView = (function(_super) {

  __extends(NPCPlayerView, _super);

  function NPCPlayerView(model, n) {
    this.model = model;
    NPCPlayerView.__super__.constructor.apply(this, arguments);
    this.tehai = new NPCTehai("tehai_" + n);
    this.kawa = new Kawa("kawa_" + n);
  }

  return NPCPlayerView;

})(PlayerView);

AgariMessage = (function() {

  function AgariMessage(action, agari, stage) {
    var i, y, _i, _len, _ref;
    if (!agari) {
      alert("フリテン");
      return;
    }
    y = "";
    _ref = agari.yakus;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      y += i.name + " ";
    }
    alert(y + "\n" + agari.message + " " + agari.score + "点");
  }

  return AgariMessage;

})();

StageInfoView = (function() {

  function StageInfoView(stage) {
    var i, j, _i, _j, _len, _len1, _ref, _ref1;
    this.stage = stage;
    this.players = this.stage.players;
    this.kyoku_label = new Label("");
    this.kyoku_label.layout_id = "kyoku_label";
    this.scores = [];
    _ref = this.players;
    for (j = _i = 0, _len = _ref.length; _i < _len; j = ++_i) {
      i = _ref[j];
      this.scores.push(new Label(""));
      this.scores[j].layout_id = this.scores[j].id = "score_" + j;
    }
    this.doras = [];
    this.kyoku_names = ["東", "南", "西", "北"];
    enchant.Game.instance.screen.addChild(this.kyoku_label);
    _ref1 = this.scores;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      i = _ref1[_j];
      enchant.Game.instance.screen.addChild(i);
    }
  }

  StageInfoView.prototype.update = function(subject, action) {
    var a, agari, i, _i, _results;
    switch (action.type) {
      case "start_kyoku":
        this.kyoku_label.text = this.kyoku_names[Math.floor((this.stage.kyoku - 1) / 4)] + ((this.stage.kyoku - 1) % 4 + 1) + "局 " + this.stage.honba + "本場";
        _results = [];
        for (i = _i = 0; _i < 4; i = ++_i) {
          _results.push(this.scores[i].text = "" + this.players[i].score);
        }
        return _results;
        break;
      case "hora":
        a = action.actor;
        agari = a.get_agari();
        return new AgariMessage(action, agari, this);
    }
  };

  StageInfoView.prototype.add_dora = function(p) {
    return dora.push(p);
  };

  return StageInfoView;

})();

MJPlayerScores = (function(_super) {

  __extends(MJPlayerScores, _super);

  function MJPlayerScores(model) {}

  MJPlayerScores.prototype.update = function(sub, a) {
    switch (a.type) {
      case "start_kyoku":
      case "reach_accepted":
        return this.updateLabel();
    }
  };

  return MJPlayerScores;

})(ViewBase);

MJRonButtons = (function() {

  MJRonButtons.prototype.imageSizeX = 30;

  MJRonButtons.prototype.imageSizeY = 30;

  function MJRonButtons() {
    var b, i, j, margin, x;
    b = {
      reach: "立直",
      pon: "ポン",
      chi: "チー",
      kan: "カン",
      ron: "ロン",
      cancel: "✕",
      tsumo: "ツモ"
    };
    this.buttons = [];
    margin = 50;
    x = 0;
    for (i in b) {
      j = b[i];
      this[i] = new Button(j);
      this[i].layout_id = "button";
      this[i].moveBy(x, 0);
      x += margin;
      this[i].visible = false;
      enchant.Game.instance.screen.addChild(this[i]);
      this.buttons.push(this[i]);
    }
  }

  MJRonButtons.prototype.hide_all = function() {
    var i, _i, _len, _ref, _results;
    _ref = this.buttons;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push(i.visible = false);
    }
    return _results;
  };

  return MJRonButtons;

})();

PaiSprite = (function(_super) {

  __extends(PaiSprite, _super);

  PaiSprite.prototype.imageSizeX = 30;

  PaiSprite.prototype.imageSizeY = 52;

  function PaiSprite(val) {
    PaiSprite.__super__.constructor.call(this, this.imageSizeX, this.imageSizeY);
    this.val = val;
    this.image = MyGame.game.assets["resource/sou5red.bmp"];
    this.frame = val;
  }

  return PaiSprite;

})(Sprite);

DraggablePai = (function(_super) {

  __extends(DraggablePai, _super);

  function DraggablePai(val) {
    var _this = this;
    DraggablePai.__super__.constructor.apply(this, arguments);
    this.addEventListener(enchant.Event.TOUCH_START, function(e) {
      return _this.touch_start(e);
    });
    this.addEventListener(enchant.Event.TOUCH_MOVE, function(e) {
      return _this.touch_move(e);
    });
    this.addEventListener(enchant.Event.TOUCH_END, function(e) {
      return _this.touch_end(e);
    });
  }

  DraggablePai.prototype.onenterframe = function() {
    if (this.lock) {
      return this.opacity = 0.5;
    } else {
      return this.opacity = 1;
    }
  };

  DraggablePai.prototype.touch_start = function(e) {
    this.sabunX = e.x - this.x;
    this.sabunY = e.y - this.y;
    this.originX = this.x;
    return this.originY = this.y;
  };

  DraggablePai.prototype.touch_move = function(e) {
    if (this.unlocked()) {
      this.moveTo(e.x - this.sabunX, e.y - this.sabunY);
    }
    if (this.selected()) {
      this.opacity = 0.6;
    }
    if (this.distance() > 10000) {
      this.touched = false;
      if (!this.selected()) {
        return this.select();
      }
    } else if (!this.touched) {
      this.deselect();
      return this.opacity = 1;
    }
  };

  DraggablePai.prototype.touch_end = function(e) {
    this.x = this.originX;
    this.y = this.originY;
    if (this.unlocked() && this.selected()) {
      this.parentNode.dispatchEvent({
        type: "mjPaiTouch",
        pai: this,
        pais: this.parentNode.select_hais
      });
      return this.deselect();
    } else {
      this.opacity = 1;
      if (this.unlocked()) {
        this.select();
        return this.touched = true;
      }
    }
  };

  DraggablePai.prototype.distance = function() {
    return Math.pow(this.x - this.originX, 2) + Math.pow(this.y - this.originY, 2);
  };

  DraggablePai.prototype.select = function() {
    return this.parentNode.select(this);
  };

  DraggablePai.prototype.selected = function() {
    return this.parentNode.selected(this);
  };

  DraggablePai.prototype.deselect = function() {
    return this.parentNode.deselect();
  };

  DraggablePai.prototype.unlocked = function() {
    return !this.lock;
  };

  return DraggablePai;

})(PaiSprite);

PaiHolder = (function(_super) {

  __extends(PaiHolder, _super);

  PaiHolder.prototype.imageSizeX = 30;

  PaiHolder.prototype.imageSizeY = 52;

  PaiHolder.prototype.maxCol = 100;

  PaiHolder.prototype.pais = [];

  function PaiHolder(layout_id) {
    PaiHolder.__super__.constructor.call(this);
    this.layout_id = layout_id;
  }

  PaiHolder.prototype.push = function(val) {
    var pai;
    this.addChild(pai = new PaiSprite(val));
    this.pais.push(pai);
    pai.moveTo(this.imageSizeX * ((this.pais.length - 1) % this.maxCol), this.imageSizeY * Math.floor((this.pais.length - 1) / this.maxCol));
    return pai.index = this.pais.length - 1;
  };

  PaiHolder.prototype.delete_at = function(pos) {
    var a;
    if (pos === -1) {
      return;
    }
    this.removeChild(a = this.pais[pos]);
    this.pais.splice(pos, 1);
    return a;
  };

  PaiHolder.prototype.pop = function() {
    return this.delete_at(this.pais.length - 1);
  };

  PaiHolder.prototype.clear = function() {
    var _results;
    _results = [];
    while (this.pais.length) {
      _results.push(this.pop());
    }
    return _results;
  };

  PaiHolder.prototype.remove = function(pai) {
    return this.delete_at(this.pais.map(function(i) {
      return i.val;
    }).indexOf(pai));
  };

  return PaiHolder;

})(CanvasGroup);

Tehai = (function(_super) {

  __extends(Tehai, _super);

  Tehai.prototype.imageSizeX = 30;

  Tehai.prototype.imageSizeY = 52;

  function Tehai(layout_id) {
    Tehai.__super__.constructor.apply(this, arguments);
    this.nakilist = [];
    this.hais = [];
    enchant.Game.instance.screen.addChild(this);
  }

  Tehai.prototype.push = function(val) {
    var pai;
    this.addChild(pai = new DraggablePai(val));
    this.pais.push(pai);
    pai.moveTo(this.imageSizeX * ((this.pais.length - 1) % this.maxCol), this.imageSizeY * Math.floor((this.pais.length - 1) / this.maxCol));
    return pai.index = this.pais.length - 1;
  };

  Tehai.prototype.sort = function() {
    var i, _i, _ref, _results;
    this.pais.sort(function(a, b) {
      if (a.val !== b.val) {
        return a.val - b.val;
      } else {
        return a.index - b.index;
      }
    });
    _results = [];
    for (i = _i = 0, _ref = this.pais.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      this.pais[i].tl.moveTo(this.imageSizeX * i, 0, 5);
      _results.push(this.pais[i].index = i);
    }
    return _results;
  };

  Tehai.prototype.clear = function() {
    var i, j, _i, _j, _len, _len1, _ref;
    Tehai.__super__.clear.apply(this, arguments);
    _ref = this.nakilist;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      for (_j = 0, _len1 = i.length; _j < _len1; _j++) {
        j = i[_j];
        this.removeChild(j);
      }
    }
    return this.nakilist = [];
  };

  Tehai.prototype.add_naki = function(h, hais, location) {
    var i, m, pai, x, _i, _ref;
    x = 400 - this.nakilist.length * 120;
    m = [];
    for (i = _i = 0, _ref = hais.length + 1; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (location === i + 1) {
        this.addChild(pai = new PaiSprite(h));
        pai.rotate(270);
        pai.moveTo(x + 10, 10);
        x += this.imageSizeY;
        m.push(pai);
      } else {
        this.addChild(pai = new PaiSprite(hais.shift()));
        pai.moveTo(x, 0);
        x += this.imageSizeX;
        m.push(pai);
      }
    }
    return this.nakilist.push(m);
  };

  return Tehai;

})(PaiHolder);

PlayerTehai = (function(_super) {

  __extends(PlayerTehai, _super);

  PlayerTehai.prototype.imageSizeX = 30;

  PlayerTehai.prototype.imageSizeY = 52;

  PlayerTehai.prototype.line_width = 4;

  function PlayerTehai(layout) {
    this.select_hais = [];
    this.select_hai_max = 1;
    this.wakus = [];
    PlayerTehai.__super__.constructor.apply(this, arguments);
    this.set_waku();
  }

  PlayerTehai.prototype.set_waku = function() {
    var i, w, _i, _results;
    _results = [];
    for (i = _i = 0; _i < 4; i = ++_i) {
      this.wakus.push(w = new Waku);
      _results.push(this.addChild(w));
    }
    return _results;
  };

  PlayerTehai.prototype.select = function(p) {
    var a, n,
      _this = this;
    if (this.select_hais.length >= this.select_hai_max) {
      this.deselect(this.select_hais[0]);
    }
    this.select_hais.push(p);
    p.addEventListener(enchant.Event.TOUCH_MOVE, a = function(e) {
      var i, n, _i, _len, _ref, _results;
      _ref = _this.select_hais;
      _results = [];
      for (n = _i = 0, _len = _ref.length; _i < _len; n = ++_i) {
        i = _ref[n];
        _this.wakus[n].visible = true;
        _this.wakus[n].x = i.x - 15;
        _results.push(_this.wakus[n].y = i.y - 15);
      }
      return _results;
    });
    n = this.select_hais.length - 1;
    this.wakus[n].x = p.x - 15;
    this.wakus[n].y = p.y - 15;
    this.wakus[n].visible = true;
    return p.waku_listener = a;
  };

  PlayerTehai.prototype.deselect = function() {
    var n, p, _i, _len, _ref;
    _ref = this.select_hais;
    for (n = _i = 0, _len = _ref.length; _i < _len; n = ++_i) {
      p = _ref[n];
      this.wakus[n].visible = false;
      p.removeEventListener(enchant.Event.TOUCH_MOVE, p.waku_listener);
    }
    return this.select_hais.length = 0;
  };

  PlayerTehai.prototype.selected = function(p) {
    return __indexOf.call(this.select_hais, p) >= 0;
  };

  PlayerTehai.prototype.lock = function() {
    var i, _i, _len, _ref, _results;
    _ref = this.pais;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push(i.lock = true);
    }
    return _results;
  };

  PlayerTehai.prototype.unlock = function() {
    var i, _i, _len, _ref, _results;
    _ref = this.pais;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push(i.lock = false);
    }
    return _results;
  };

  return PlayerTehai;

})(Tehai);

NPCTehai = (function(_super) {

  __extends(NPCTehai, _super);

  function NPCTehai(layout) {
    NPCTehai.__super__.constructor.apply(this, arguments);
    this.pais = [];
  }

  NPCTehai.prototype.remove = function(a) {
    return this.delete_at(Math.floor(Math.random() * this.pais.length));
  };

  NPCTehai.prototype.push = function(val) {
    var pai;
    this.addChild(pai = new PaiSprite(34));
    this.pais.push(pai);
    pai.moveTo(this.imageSizeX * ((this.pais.length - 1) % this.maxCol), this.imageSizeY * Math.floor((this.pais.length - 1) / this.maxCol));
    return pai.index = this.pais.length - 1;
  };

  return NPCTehai;

})(Tehai);

Waku = (function(_super) {

  __extends(Waku, _super);

  Waku.prototype.imageSizeX = 30;

  Waku.prototype.imageSizeY = 52;

  Waku.prototype.line_width = 4;

  function Waku() {
    Waku.__super__.constructor.call(this, 100, 100);
    this.visible = false;
    this.image = new Surface(100, 100);
    this.image.context.shadowBlur = 20;
    this.image.context.shadowColor = "rgb(255,128,0)";
    this.image.context.strokeStyle = "rgb(255,128,0)";
    this.image.context.lineWidth = this.line_width;
    this.image.context.strokeRect(this.line_width + 10, this.line_width + 10, this.imageSizeX + this.line_width / 2, this.imageSizeY + this.line_width / 2);
    this.opacity = 0.6;
  }

  return Waku;

})(Sprite);

Kawa = (function(_super) {

  __extends(Kawa, _super);

  Kawa.prototype.imageSizeX = 30 * 0.8;

  Kawa.prototype.imageSizeY = 52 * 0.8;

  function Kawa(layout) {
    Kawa.__super__.constructor.apply(this, arguments);
    enchant.Game.instance.screen.addChild(this);
    this.pais = [];
    this.maxCol = 6;
  }

  Kawa.prototype.push = function(val) {
    var pai;
    this.addChild(pai = new PaiSprite(val));
    pai.scale(0.8, 0.8);
    this.pais.push(pai);
    pai.moveTo(this.imageSizeX * ((this.pais.length - 1) % this.maxCol), this.imageSizeY * Math.floor((this.pais.length - 1) / this.maxCol));
    return pai.index = this.pais.length - 1;
  };

  return Kawa;

})(PaiHolder);

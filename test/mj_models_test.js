//var stage=new Stage;
//module("Stage");

var player=null;

module("Player",{
	setup:function(){
		player=new Player;
	}
});

function array_equal(arr1,arr2){
	if(arr1.length!=arr2.length){
		return false;
	}
	var a=arr1.slice();
	var b=arr2.slice();

	a.sort();
	b.sort();

	console.log(a,b)
	
	for(var i=0;i<a.length;i++){
		if(a[i] instanceof Array){
			if(a[i].length!=b[i].length)
				return false;
			for(var j=0;j<a[i].length;j++){
				if(a[i][j]!==b[i][j]){
					return false;
				}
			}

		}
		else{
			if(a[i]!==b[i]){
				return false;
			}
		}
	}
	return true;
}

test("tsumo",function(){
	for(var i=0;i<13;i++){
		player.tsumo({type:"tsumo",pai:i,actor:player});
	}
	player.tsumo({type:"tsumo",pai:1,actor:player});
	ok(player.tehai[player.tehai.length-1]==1);
	ok(array_equal(player.tehai,[0,1,2,3,4,5,6,7,8,9,10,11,12,1]));
});


test("dahai",function(){
	player.tehai=[0,1,2,3,4,5,6,7,8,9,10,11,12,1];
	player.dahai({type:"dahai",pai:1,actor:player});
	ok(array_equal(player.tehai,[0,1,2,3,4,5,6,7,8,9,10,11,12]));
	ok(player.kawa[player.kawa.length-1]==1);
});


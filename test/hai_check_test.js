var checker=null;
module("HaiChecker",{
	setup:function(){
		var states=new DummyMJPlayerStates;
		checker=new HaiChecker(states);
	}
});

test("can_agari",function(){
	var arr=[0,0,1,2,3,4,5,6,12,13,14,2,3];
	for(var i=0;i<13;i++){
		checker.push_tehai(arr[i]);
	}
	checker.check_agari();
	ok(!checker.can_agari());
	checker.push_tehai(4);
	checker.check_agari();
	ok(checker.can_agari());
	
});

test("平和形待ち計算",function(){
	var arr=[0,0,1,2,3,4,5,6,12,13,14,19,20,27];
	for(var i=0;i<14;i++){
		checker.push_tehai(arr[i]);
	}
	checker.check_agari();
	var machis=checker.machis;
	ok(machis);
	ok(array_equal(machis,[[18,27],[21,27]]));
	checker.dahai(3);
	checker.check_agari();
	ok(checker.machis.length==0);
});

test("純正九蓮待ち計算",function(){
	var arr=[0,0,0,1,2,3,4,5,6,7,8,8,8];
	for(var i=0;i<13;i++){
		checker.push_tehai(arr[i]);
	}
	checker.check_agari();
	var machis;
	ok(machis=checker.machis);
	console.log(machis);
	ok(array_equal(machis.map(function(i){return i[0]}),[0,1,2,3,4,5,6,7,8]));
});
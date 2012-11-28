function generateCombinations(array, r, callback) {
    function equal(a, b) {
        for (var i = 0; i < a.length; i++) {
            if (a[i] != b[i]) return false;
        }
        return true;
    }
    function values(i, a) {
        var ret = [];
        for (var j = 0; j < i.length; j++) ret.push(a[i[j]]);
        return ret;
    }
    var n = array.length;
    var indices = [];
    for (var i = 0; i < r; i++) indices.push(i);
    var final = [];
    for (var i = n - r; i < n; i++) final.push(i);
    while (!equal(indices, final)) {
        callback(values(indices, array));
        var i = r - 1;
        while (indices[i] == n - r + i) i -= 1;
        indices[i] += 1;
        for (var j = i + 1; j < r; j++) indices[j] = indices[i] + j - i;
    }
    callback(values(indices, array));
}
/*
var a=["aaa","bbb","ccc","ddd"];
generateCombinations(a,2,function(elem){
    for(var i=0;i<elem.length;i++){
      console.log(elem[i]);
    }
    console.log("|");
  }
)*/
Array.prototype.shuffle = function() {
    var i = this.length;
    while(i){
        var j = Math.floor(Math.random()*i);
        var t = this[--i];
        this[i] = this[j];
        this[j] = t;
    }
    return this;
};
Array.prototype.uniq = function(){
    var o = new Object;
    var result = new Array;
    for(var i = 0, l = this.length; i < l; i++){
        var e = this[i];
        if(!(e in o) || o[e].indexOf(typeof this[i]) == -1){
            o[e] += typeof e;
            result.push(e);
        }
    }
    
    return result;
};
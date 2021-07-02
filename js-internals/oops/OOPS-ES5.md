function Person(n,race){ 
	this.constructor.population++;

	// ************************************************************************ 
	// PRIVATE VARIABLES AND FUNCTIONS 
	// ONLY PRIVELEGED METHODS MAY VIEW/EDIT/INVOKE 
	// *********************************************************************** 
	var alive=true, age=1;
	var maxAge=70+Math.round(Math.random()*15)+Math.round(Math.random()*15);
	function makeOlder(){ return alive = (++age <= maxAge) } 

	var myName=n?n:"John Doe";
	var weight=1;


	// ************************************************************************ 
	// PRIVILEGED METHODS 
	// MAY BE INVOKED PUBLICLY AND MAY ACCESS PRIVATE ITEMS 
	// MAY NOT BE CHANGED; MAY BE REPLACED WITH PUBLIC FLAVORS 
	// ************************************************************************ 
	this.toString=this.getName=function(){ return myName } 

	this.eat=function(){ 
		if (makeOlder()){ 
			this.dirtFactor++;
			return weight*=3;
		} else alert(myName+" can't eat, he's dead!");
	} 
	this.exercise=function(){ 
		if (makeOlder()){ 
			this.dirtFactor++;
			return weight/=2;
		} else alert(myName+" can't exercise, he's dead!");
	} 
	this.weigh=function(){ return weight } 
	this.getRace=function(){ return race } 
	this.getAge=function(){ return age } 
	this.muchTimePasses=function(){ age+=50; this.dirtFactor=10; } 


	// ************************************************************************ 
	// PUBLIC PROPERTIES -- ANYONE MAY READ/WRITE 
	// ************************************************************************ 
	this.clothing="nothing/naked";
	this.dirtFactor=0;
} 


// ************************************************************************ 
// PUBLIC METHODS -- ANYONE MAY READ/WRITE
// CAN'T ACCESS THE PRIVATE VARIABLES AND METHODS 
// ************************************************************************ 
Person.prototype.beCool = function(){ this.clothing="khakis and black shirt" } 
Person.prototype.shower = function(){ this.dirtFactor=2 } 
Person.prototype.showLegs = function(){ alert(this+" has "+this.legs+" legs") } 
Person.prototype.amputate = function(){ this.legs-- } 


// ************************************************************************ 
// PROTOTYOPE PROERTIES -- ANYONE MAY READ/WRITE (but may be overridden) 
// ************************************************************************ 
Person.prototype.legs=2;


// ************************************************************************ 
// STATIC PROPERTIES -- ANYONE MAY READ/WRITE 
// ************************************************************************ 
Person.population = 0;


var p = new Person()

p.constructor === Person  //true

Person.prototype === p.__proto__ //true

"use strict";

let retweet = function(event){
    if(event.target.nodeName == "INPUT"){
        let newWindow = event.target.id;
        console.log(newWindow);
        window.open(newWindow);
    }
};
document.getElementById("tweets").addEventListener("click", retweet);
document.querySelector('.banner').addEventListener("click", function(){
    document.getElementById("clarification").innerHTML = "Started out as a website for my mom, time had other plans";
});
document.getElementById("card").addEventListener("click", function(){
    let magic = document.createElement("img");
    magic.src = "/assets/card.jpg";
    magic.id = "fix";
    document.getElementById("magicTrick").appendChild(magic);
});

(()=>{"use strict";class t{withFields(t){let e=Object.keys(this).map((e=>e in t?t[e]:this[e]));return new this.constructor(...e)}}class e{static fromArray(t,e){let n=e||new o;for(let e=t.length-1;e>=0;--e)n=new s(t[e],n);return n}[Symbol.iterator](){return new i(this)}toArray(){return[...this]}atLeastLength(t){for(let e of this){if(t<=0)return!0;t--}return t<=0}hasLength(t){for(let e of this){if(t<=0)return!1;t--}return 0===t}countLength(){let t=0;for(let e of this)t++;return t}}function n(t,e){return new s(t,e)}function r(t,n){return e.fromArray(t,n)}class i{#t;constructor(t){this.#t=t}next(){if(this.#t instanceof o)return{done:!0};{let{head:t,tail:e}=this.#t;return this.#t=e,{value:t,done:!1}}}}class o extends e{}class s extends e{constructor(t,e){super(),this.head=t,this.tail=e}}class a extends t{static isResult(t){return t instanceof a}}class u extends a{constructor(t){super(),this[0]=t}isOk(){return!0}}class l extends a{constructor(t){super(),this[0]=t}isOk(){return!1}}function c(t,e){let n=[t,e];for(;n.length;){let t=n.pop(),e=n.pop();if(t===e)continue;if(!m(t)||!m(e))return!1;if(!x(t,e)||d(t,e)||h(t,e)||w(t,e)||p(t,e)||y(t,e)||g(t,e))return!1;const r=Object.getPrototypeOf(t);if(null!==r&&"function"==typeof r.equals)try{if(t.equals(e))continue;return!1}catch{}let[i,o]=f(t);for(let r of i(t))n.push(o(t,r),o(e,r))}return!0}function f(t){if(t instanceof Map)return[t=>t.keys(),(t,e)=>t.get(e)];{let e=t instanceof globalThis.Error?["message"]:[];return[t=>[...e,...Object.keys(t)],(t,e)=>t[e]]}}function d(t,e){return t instanceof Date&&(t>e||t<e)}function h(t,e){return t.buffer instanceof ArrayBuffer&&t.BYTES_PER_ELEMENT&&!(t.byteLength===e.byteLength&&t.every(((t,n)=>t===e[n])))}function w(t,e){return Array.isArray(t)&&t.length!==e.length}function p(t,e){return t instanceof Map&&t.size!==e.size}function y(t,e){return t instanceof Set&&(t.size!=e.size||[...t].some((t=>!e.has(t))))}function g(t,e){return t instanceof RegExp&&(t.source!==e.source||t.flags!==e.flags)}function m(t){return"object"==typeof t&&null!==t}function x(t,e){return!!("object"==typeof t||"object"==typeof e||t&&e)&&(![Promise,WeakSet,WeakMap,Function].some((e=>t instanceof e))&&t.constructor===e.constructor)}function v(t,e){return 0===e?0:t%e}function b(t,e){return 0===e?0:t/e}function k(t,e,n,r,i,o){let s=new globalThis.Error(i);s.gleam_error=t,s.module=e,s.line=n,s.function=r,s.fn=r;for(let t in o)s[t]=o[t];return s}class E extends t{}class _ extends t{}class M extends t{}function L(t,e,n){return t?e:n()}function F(t){return function(t,e){for(;;){let r=t,i=e;if(r.hasLength(0))return i;{let o=r.head;t=r.tail,e=n(o,i)}}}(t,r([]))}function P(t){if(t.hasLength(0))return new l(void 0);{let e=t.head;return new u(e)}}function S(t,e){return function(t,e,r){for(;;){let i=t,o=e,s=r;if(i.hasLength(0))return F(s);{let a=i.head;t=i.tail,e=o,r=n(o(a),s)}}}(t,e,r([]))}function O(t,e,n){for(;;){let r=t,i=e,o=n;if(r.hasLength(0))return i;{let s=r.head;t=r.tail,e=o(i,s),n=o}}}function A(t,e,i){return function(t,e){return[t[0],e(t[1])]}(O(t,[e,r([])],((t,e)=>{let r=t[0],o=t[1],s=i(r,e);return[s[0],n(s[1],o)]})),F)}function B(t,e){for(;;){let n=t,r=e;if(n.hasLength(0))return!0;{let i=n.head,o=n.tail;if(!r(i))return!1;t=o,e=r}}}function I(t){if(t.hasLength(0))return r([]);{let e=t.head,i=t.tail;return n(e,I(function(t,e){return function(t,e,r){for(;;){let i=t,o=e,s=r;if(i.hasLength(0))return F(s);{let a=i.head,u=i.tail,l=o(a)?n(a,s):s;t=u,e=o,r=l}}}(t,e,r([]))}(i,(t=>!c(t,e)))))}}function C(t,e){return function(t,e,r){for(;;){let i=t,o=e,s=r,a=U(i,o);if(a instanceof _)return n(o,s);a instanceof M?(t=i,e=o+1,r=n(o,s)):(t=i,e=o-1,r=n(o,s))}}(t,e,r([]))}function j(t,e){let n=T(e),r=(i=t,o=n,Math.trunc(b(i,o)));var i,o;let s=v(t,n);return function(t,e,n){for(;;){let r=t;if(e<=0)return n;t=r,e-=1,n+=r}}(e,r,"")+function(t,e,n){if(n<0)return"";if(e<0){let r=T(t)+e;return r<0?"":N(t,r,n)}return N(t,e,n)}(e,0,s)}function $(t,e,n){let r=e-T(t);return r<=0?t:j(r,n)+t}function T(t){if(""===t)return 0;const e=W(t);if(e){let t=0;for(const n of e)t++;return t}return t.match(/./gsu).length}let R;function W(t){if(globalThis.Intl&&Intl.Segmenter)return R||=new Intl.Segmenter,R.segment(t)[Symbol.iterator]()}function N(t,e,n){if(n<=0||e>=t.length)return"";const r=W(t);if(r){for(;e-- >0;)r.next();let t="";for(;n-- >0;){const e=r.next().value;if(void 0===e)break;t+=e.segment}return t}return t.match(/./gsu).slice(e,e+n).join("")}new WeakMap,new DataView(new ArrayBuffer(8)),Math.pow(2,5),Symbol();const Y=[" ","\t","\n","\v","\f","\r","","\u2028","\u2029"].join("");function q(t){return Math.floor(t)}function z(t){return Math.round(t)}function D(){const t=Math.random();return 1===t?D():t}function H(t){return t>=0?t:0-t}function X(t){return t>=0?z(t):0-z(function(t){return-1*t}(t))}function J(t){return t.toString(16).toUpperCase()}function U(t,e){return t===e?new _:t<e?new E:new M}function V(t){return X(q(D()*t))}new RegExp(`^[${Y}]*`),new RegExp(`[${Y}]*$`);let G,K,Q,Z,tt={},et={},nt={x:0,y:0};function rt(){const t=document.getElementById(G);K/Q>=window.innerWidth/window.innerHeight?(t.width=window.innerWidth,Z=window.innerWidth/K,t.height=Q*Z,t.style.top=(window.innerHeight-t.height)/2+"px",t.style.left="0px"):(t.height=window.innerHeight,Z=window.innerHeight/Q,t.width=K*Z,t.style.top="0px",t.style.left=(window.innerWidth-t.width)/2+"px"),t.getContext("2d").imageSmoothingEnabled=!1}let it,ot=[],st={},at=0;function ut(t,e,n,r,i){function o(t,r){const i=t-at;if(i>16.6){it=i,n(r);const s=e(r);at=t,function(){for(const t in tt)tt[t]&=1;for(const t in et)et[t]&=1}(),requestAnimationFrame((t=>o(t,s)))}else requestAnimationFrame((t=>o(t,r)))}const s=document.getElementById(G);s.getContext("2d").imageSmoothingEnabled=!1,s.style.display="block",window.addEventListener("keydown",(t=>{tt[t.code]=3})),window.addEventListener("keyup",(t=>{tt[t.code]=4})),window.addEventListener("mousedown",(t=>{et[t.button]=3,nt.x=t.clientX,nt.y=t.clientY})),window.addEventListener("touchstart",(t=>{et[0]=3,nt.x=t.touches[0].clientX,nt.y=t.touches[0].clientY})),window.addEventListener("mouseup",(t=>{et[t.button]=4})),window.addEventListener("touchend",(t=>{et[0]=4})),window.addEventListener("mousemove",(t=>{nt.x=t.clientX,nt.y=t.clientY})),window.addEventListener("touchmove",(function(t){nt.x=t.touches[0].clientX,nt.y=t.touches[0].clientY}));const a=r.toArray().map(((t,e)=>new Promise((n=>{const r=new Image;r.onload=()=>{ot[e]=r,n()},r.onerror=()=>{console.error(`Failed to load image ${e}`)},r.src=t})))),u=i.toArray().map((async(t,e)=>{if(t.endsWith(".js"))try{await async function(t,e){const n=await fetch(t),r=await n.text(),i=JSON.parse(r.replace(/\[,/g,"[null,").replace(/,,\]/g,",null]").replace(/,\s*(?=[,\]])/g,",null").replace(/([\[,]-?)(?=\.)/g,"$10").replace(/-\./g,"-0."),((t,e)=>null===e?void 0:e)),o=wt(...i);st[e]=o,pt[e]=1}(t,e)}catch(n){await async function(t,e){const n=await fetch(t),r=await n.text(),i=JSON.parse(r.replace(/\[,/g,"[null,").replace(/,,\]/g,",null]").replace(/,\s*(?=[,\]])/g,",null").replace(/([\[,]-?)(?=\.)/g,"$10").replace(/-\./g,"-0."),((t,e)=>null===e?void 0:e)),o=ct(...i);st[e]=o,pt[e]=0}(t,e)}else await async function(t,e){const n=await fetch(t),r=await n.arrayBuffer();st[e]=await ht.decodeAudioData(r),pt[e]=2}(t,e)}));Promise.all([Promise.all(a),Promise.all(u)]).then((()=>{const e=t();requestAnimationFrame((t=>o(t,e)))})).catch((t=>{console.error("Failed to start engine:",t)}))}const lt=(...t)=>{let e=ht.createBufferSource(),n=ht.createBuffer(t.length,t[0].length,dt);return t.map(((t,e)=>n.getChannelData(e).set(t))),e.buffer=n,e.connect(ht.destination),e.start(),e},ct=(t=1,e=.05,n=220,r=0,i=0,o=.1,s=0,a=1,u=0,l=0,c=0,f=0,d=0,h=0,w=0,p=0,y=0,g=1,m=0,x=0)=>{let v,b,k=2*Math.PI,E=u*=500*k/dt**2,_=(0<w?1:-1)*k/4,M=n*=(1+2*e*Math.random()-e)*k/dt,L=[],F=0,P=0,S=0,O=1,A=0,B=0,I=0;for(l*=500*k/dt**3,w*=k/dt,c*=k/dt,f*=dt,d=dt*d|0,b=(r=99+dt*r)+(m*=dt)+(i*=dt)+(o*=dt)+(y*=dt)|0;S<b;L[S++]=I)++B%(100*p|0)||(I=s?1<s?2<s?3<s?Math.sin((F%k)**3):Math.max(Math.min(Math.tan(F),1),-1):1-(2*F/k%2+2)%2:1-4*Math.abs(Math.round(F/k)-F/k):Math.sin(F),I=(d?1-x+x*Math.sin(2*Math.PI*S/d):1)*(0<I?1:-1)*Math.abs(I)**a*t*ft*(S<r?S/r:S<r+m?1-(S-r)/m*(1-g):S<r+m+i?g:S<b-y?(b-S-y)/o*g:0),I=y?I/2+(y>S?0:(S<b-y?1:(b-S)/y)*L[S-y|0]/2):I),v=(n+=u+=l)*Math.sin(P*w-_),F+=v-v*h*(1-1e9*(Math.sin(S)+1)%2),P+=v-v*h*(1-1e9*(Math.sin(S)**2+1)%2),O&&++O>f&&(n+=c,M+=c,O=0),!d||++A%d||(n=M,u=E,O=O||1);return L},ft=.3,dt=44100,ht=new(window.AudioContext||webkitAudioContext),wt=(t,e,n,r=125)=>{let i,o,s,a,u,l,c,f,d,h,w,p,y,g,m,x=0,v=[],b=[],k=[],E=0,_=0,M=1,L={},F=dt/r*60>>2;for(;M;E++)v=[M=f=w=y=0],n.map(((r,w)=>{for(c=e[r][E]||[0,0,0],M|=!!e[r][E],m=y+(e[r][0].length-2-!f)*F,g=w==n.length-1,o=2,a=y;o<c.length+g;f=++o){for(u=c[o],d=o==c.length+g-1&&g||h!=(c[0]||0)|u,s=0;s<F&&f;s++>F-99&&d?p+=(p<1)/99:0)l=(1-p)*v[x++]/2||0,b[a]=(b[a]||0)-l*_+l,k[a]=(k[a++]||0)+l*_+l;u&&(p=u%1,_=c[1]||0,(u|=0)&&(v=L[[h=c[x=0]||0,u]]=L[[h,u]]||(i=[...t[h]],i[2]*=2**((u-12)/12),u>0?ct(...i):[])))}y=m}));return[b,k]};let pt=[];async function yt(){const t=st._currentNode;t&&(await ht.suspend(),t.stop(),t.disconnect(),st._currentNode=null)}class gt extends t{constructor(t,e,n,r){super(),this.r=t,this.g=e,this.b=n,this.a=r}}function mt(t,e,n){if(t>=0&&t<360&&e>=0&&e<=100&&n>=0&&n<=100){let i=b(e*(100-function(t){return t>=0?t:-1*t}(2*n-100)),1e4),o=(r=b(t,60),0==2?new l(void 0):new u(r-2*q(b(r,2))));if(!o.isOk())throw k("let_assert","kitten/color",396,"from_hsl","Pattern match failed, no pattern matched the value.",{value:o});let s=o[0],a=i*(1-H(s-1)),c=(()=>{if(0<=t&&t<60)return[i,a,0];if(60<=t&&t<120)return[a,i,0];if(120<=t&&t<180)return[0,i,a];if(180<=t&&t<240)return[0,a,i];if(240<=t&&t<300)return[a,0,i];if(300<=t&&t<360)return[i,0,a];throw k("panic","kitten/color",405,"from_hsl","unreachable",{})})(),f=c[0],d=c[1],h=c[2],w=b(n,100)-b(i,2);return new u(new gt(X(255*(f+w)),X(255*(d+w)),X(255*(h+w)),1))}return new l(void 0);var r}function xt(t){return function(t){return"#"+$(J(t.r),2,"0")+$(J(t.g),2,"0")+$(J(t.b),2,"0")}(t)+$(J(X(255*t.a)),2,"0")}const vt=new gt(255,255,255,1),bt=new gt(0,0,0,1),kt=new gt(217,53,38,1),Et=new gt(14,17,24,1);class _t extends t{constructor(t,e){super(),this.x=t,this.y=e}}function Mt(t,e){return new _t(t.x+e.x,t.y+e.y)}function Lt(t,e){return new _t(t.x-e.x,t.y-e.y)}function Ft(t,e){return new _t(t.x*e.x,t.y*e.y)}function Pt(t,e){return t.x*e.x+t.y*e.y}function St(t){let e=(n=function(t){return t.x*t.x+t.y*t.y}(t),function(t,e){let n=(r=e,Math.ceil(r)-e>0);var r;return t<0&&n||0===t&&e<0?new l(void 0):new u(function(t,e){return Math.pow(t,e)}(t,e))}(n,.5));var n;if(!e.isOk())throw k("let_assert","kitten/vec2",110,"length","Pattern match failed, no pattern matched the value.",{value:e});return e[0]}function Ot(t,e){return new _t(t.x*e,t.y*e)}function At(t,e,n,r){return function(t,e,n,r,i,o){const s=e-r/2,a=n-i/2;return t.fillStyle=o,t.fillRect(s,a,r,i),t}(t,e.x,e.y,n.x,n.y,xt(r))}function Bt(t,e,n,r,i,o,s,a){return function(t,e,n,r,i,o,s,a,u){return t.fillStyle=u,t.textAlign="center",t.font=`${o} ${i}px ${s}`,t.save(),t.scale(1,-1),t.translate(n,-r),t.rotate(a),t.fillText(e,0,-0),t.restore(),t}(t,e,n.x,n.y,r,i,o,s,xt(a))}class It extends t{}class Ct extends t{}function jt(t){return function(t){return!!(4&et[t])}(function(t){return t instanceof It?0:t instanceof Ct?1:2}(t))}function $t(){let t=function(){const t=document.getElementById(G),e=t.getBoundingClientRect(),n=e.left,r=e.top,i=t.getContext("2d").getTransform().invertSelf(),o=nt.x-n,s=nt.y-r;return[i.a*o+i.c*s+i.e,i.b*o+i.d*s+i.f]}();return new _t((e=t)[0],e[1]);var e}function Tt(t,e,n,r){return 2*H(t.x-n.x)<=e.x+r.x&&2*H(t.y-n.y)<=e.y+r.y}function Rt(t,e){return Mt(Ot(e,60*it/1e3),t)}class Wt extends t{constructor(t){super(),this.id=t}}class Nt extends t{constructor(t){super(),this.id=t}}class Yt extends t{constructor(t){super(),this.id=t}}function qt(t){return t instanceof Nt?async function(t){if(!st[t])throw new Error(`Song "${t}" not found in the library.`);yt();const e=st[t],n=lt(...e);n.loop=!1,await ht.resume(),st._currentNode=n}(t.id):t instanceof Wt?(e=t.id,void lt(st[e])):async function(t){yt(),await ht.resume();const e=ht.createBufferSource();e.buffer=st[t],e.connect(ht.destination),e.start(0),st._currentNode=e}(t.id);var e}class zt extends t{constructor(t,e,n,r,i,o,s){super(),this.player=t,this.direction=e,this.balls=n,this.blocks=r,this.cooldown=i,this.palette=o,this.hit_sound=s}}class Dt extends t{}class Ht extends t{}class Xt extends t{}class Jt extends t{}class Ut extends t{constructor(t,e,n){super(),this.pos=t,this.is_showing=e,this.durability=n}}class Vt extends t{constructor(t,e,n){super(),this.pos=t,this.vel=e,this.state=n}}class Gt extends t{}class Kt extends t{}class Qt extends t{}class Zt extends t{constructor(t,e,n,r,i){super(),this.dur10=t,this.dur20=e,this.dur30=n,this.dur40=r,this.dur50=i}}const te=new _t(40,40);const ee=new _t(16,16);function ne(t,e,n){let r=A(t,e,((t,e)=>{let r=A(t,e,((t,e)=>L(!e.is_showing,[t,e],(()=>{let r=Tt(t.pos,ee,e.pos,te)?(qt(n),e.durability-1):e.durability,i=r>0;return L(!i,[t,e.withFields({durability:0,is_showing:!1})],(()=>{let n=function(t,e,n,r){let i=t[0],o=t[1],s=t[2],a=t[3],u=e[0],l=e[1],c=e[2],f=e[3];return L(!Tt(i,o,u,l),[[i,s],[u,c]],(()=>{let t=b(o.x+l.x,2)-H(i.x-u.x),e=b(o.y+l.y,2)-H(i.y-u.y),d=t<e?[t,(()=>{let t=i.x<u.x;return new _t(t?1:-1,0)})()]:[e,(()=>{let t=i.y<u.y;return new _t(0,t?1:-1)})()],h=d[0],w=d[1],p=0===a&&0===f?[i,u]:0===f?[Lt(i,Ot(w,h)),u]:0===a?[i,Mt(u,Ot(w,h))]:[Lt(i,Ot(w,.5*h)),Mt(u,Ot(w,.5*h))],y=p[0],g=p[1],m=Lt(c,s),x=Pt(m,w);return L(x>0,[[i,s],[u,c]],(()=>{let t=b((-1-n)*x,b(1,a)+b(1,f)),e=Ot(w,t),i=Ot(e,b(1,a)),o=Ot(e,b(1,f)),u=new _t(0-w.y,w.x);var l,d;let h=Ot(u,function(t,e){return t>e?t:e}((l=0-b(Pt(m,u),b(1,a)+b(1,f)))<(d=r*t)?l:d,0-r*t)),p=Ot(h,b(1,a)),v=Ot(h,b(1,f)),k=(()=>{let t=Lt(s,i);return Lt(t,p)})(),E=(()=>{let t=Mt(c,o);return Mt(t,v)})();return[[y,k],[g,E]]}))}))}([t.pos,ee,t.vel,10],[e.pos,te,new _t(0,0),0],1,0),o=n[0][0],s=n[0][1];return[t.withFields({pos:o,vel:s}),e.withFields({durability:r,is_showing:i})]}))}))));return function(t){let e=t[0];return[t[1],e]}(r)})),i=r[0];return[S(r[1],(t=>{let e=t.pos.y<-300?new Vt((i=t.pos,o=-300,new _t(i.x,o)),new _t(0,0),new Qt):t,r=e.pos.x>=300&&e.vel.x>0||e.pos.x<=-300&&e.vel.x<0?(qt(n),e.withFields({vel:Ft(e.vel,new _t(-1,1))})):e;var i,o;return r.pos.y>=300?(qt(n),r.withFields({vel:Ft(r.vel,new _t(1,-1))})):r})),i]}!function(t,e,n,r,i,o,s,a){(function(t,e,n,r,i,o,s,a){document.body.style.margin="0",document.body.style.padding="0",document.body.style.overflow="hidden",document.documentElement.style.margin="0",document.documentElement.style.padding="0",document.documentElement.style.overflow="hidden",document.getElementById(r).style.position="absolute",G=r,K=i,Q=o,rt(),window.addEventListener("resize",(()=>rt())),ut(t,e,n,s,a)})(t,e,n,r,i,o,s,a)}((function(){let t=S(C(0,29),(t=>new Vt(new _t(0,-300),new _t(0,0),new Kt))),e=(()=>{let t=S(C(0,9),(t=>[V(10),V(10),V(49)+1]));return S(I(t),(t=>{let e=t[0],n=t[1],r=t[2];return new Ut(new _t((e-5)*te.x,(n-5)*te.y),!0,r)}))})(),n=mt(0,90,50);if(!n.isOk())throw k("let_assert","breakout",85,"init","Pattern match failed, no pattern matched the value.",{value:n});let r=n[0],i=mt(40,90,50);if(!i.isOk())throw k("let_assert","breakout",86,"init","Pattern match failed, no pattern matched the value.",{value:i});let o=i[0],s=mt(80,90,50);if(!s.isOk())throw k("let_assert","breakout",87,"init","Pattern match failed, no pattern matched the value.",{value:s});let a=s[0],c=mt(120,90,50);if(!c.isOk())throw k("let_assert","breakout",88,"init","Pattern match failed, no pattern matched the value.",{value:c});let f=c[0],d=mt(160,90,50);if(!d.isOk())throw k("let_assert","breakout",89,"init","Pattern match failed, no pattern matched the value.",{value:d});let h=d[0],w=new Zt(r,o,a,f,h),p=function(t){let e=function(t){return pt[t]||0===pt[t]?[!0,pt[t]]:[!1,-1]}(t);return e[0]&&0===e[1]?new u(new Wt(t)):e[0]&&1===e[1]?new u(new Nt(t)):e[0]&&2===e[1]?new u(new Yt(t)):new l(void 0)}(0);if(!p.isOk())throw k("let_assert","breakout",93,"init","Pattern match failed, no pattern matched the value.",{value:p});let y=p[0];return new zt(new Dt,new _t(0,0),t,e,0,w,y)}),(function(t){let e=t.player;if(e instanceof Dt){let e=B(t.blocks,(t=>!t.is_showing)),r=jt(new It)&&function(t,e,n){return Tt(t,new _t(0,0),e,n)}($t(),new _t(0,0),new _t(620,620));if(e)return t.withFields({player:new Jt});if(r){let e=P(t.balls);if(!e.isOk())throw k("let_assert","breakout",108,"update","Pattern match failed, no pattern matched the value.",{value:e});let r=e[0],i=Ot(n=Lt($t(),r.pos),b(5,St(n)));return t.withFields({player:new Ht,direction:i})}return t}var n;if(e instanceof Ht){let e=function(t,e){if(t.hasLength(0))return new l(void 0);{let n=t.head,r=t.tail;return new u(O(r,n,e))}}(t.balls,((t,e)=>e));if(!e.isOk())throw k("let_assert","breakout",117,"update","Pattern match failed, no pattern matched the value.",{value:e});if(c(e[0].state,new Gt))return t.withFields({player:new Xt});{let e=ne(S(A(t.balls,!0,((e,n)=>{let r=t.cooldown>=4,i=n.state;return r?e&&i instanceof Kt?[!1,n.withFields({vel:t.direction,state:new Gt})]:e?[!0,n]:[!1,n]:[!1,n]}))[1],(t=>t.withFields({pos:Rt(t.pos,t.vel)}))),t.blocks,t.hit_sound),n=e[0],r=e[1];return t.withFields({balls:n,blocks:r,cooldown:v(t.cooldown+1,5)})}}if(e instanceof Xt){if(B(t.balls,(t=>c(t.state,new Qt)))){let e=P(S(t.balls,(t=>t.pos)));if(!e.isOk())throw k("let_assert","breakout",146,"update","Pattern match failed, no pattern matched the value.",{value:e});let n=e[0],r=S(t.balls,(t=>t.withFields({pos:n,state:new Kt})));return t.withFields({balls:r,player:new Dt})}{let e=ne(S(t.balls,(t=>t.withFields({pos:Rt(t.pos,t.vel)}))),t.blocks,t.hit_sound),n=e[0],r=e[1];return t.withFields({balls:n,blocks:r})}}return t}),(function(t){let e=function(t,e){return function(t,e){return t.canvas.style.backgroundColor=e,K&&(document.body.style.backgroundColor=e),t}(t,xt(e))}(function(){const t=document.getElementById(G),e=t.getContext("2d");return e.setTransform(1,0,0,1,0,0),e.clearRect(0,0,t.width,t.height),e.setTransform(1,0,0,-1,t.width/2,t.height/2),e.scale(Z,Z),e}(),bt);var n;let r=At(((n=e).scale(1.5,1.5),n),new _t(0,313),new _t(636,10),Et),i=At(r,new _t(0,-313),new _t(636,10),Et),o=At(i,new _t(313,0),new _t(10,620),Et),s=At(o,new _t(-313,0),new _t(10,620),Et),a=(t.player instanceof Jt?t=>Bt(t,"You win!",new _t(0,0),200,300,"Arial",0,kt):e=>O(t.blocks,e,((e,n)=>{if(n.is_showing){let r=n.durability,i=r>=40?t.palette.dur50:r>=30?t.palette.dur40:r>=20?t.palette.dur30:r>=10?t.palette.dur20:t.palette.dur10;return Bt(At(e,n.pos,te,i),n.durability.toString(),Lt(n.pos,new _t(0,7)),18,200,"Arial",0,bt)}return e})))(s);var u;u=a,O(t.balls,u,((t,e)=>function(t,e,n,r){return function(t,e,n,r,i){return t.fillStyle=i,t.beginPath(),t.arc(e,n,r,0,2*Math.PI),t.fill(),t}(t,e.x,e.y,n,xt(r))}(t,e.pos,b(ee.x,2),vt)))}),"canvas",1920,1080,r([]),r(["hit.js"]))})();
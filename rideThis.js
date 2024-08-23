gsap.from(".letter", 0.8, {
  y: -20,
  opacity: 0,
  ease: "power3.inout",
  stagger: 0.1,
});

gsap.to(".top-left, .top-right", 2, {
  top: "0",
  ease: "power3.inOut",
  delay: 2,
});

gsap.to(".bottom-right", 2, {
  bottom: "0",
  ease: "power3.inOut",
  delay: 2,
});

gsap.to(".top-left", 2, {
  left: "0",
  ease: "power3.inOut",
  delay: 4,
});

gsap.to(".top-right", 2, {
  right: "0",
  ease: "power3.inOut",
  delay: 4,
});

gsap.to(".bottom-right", 2, {
  right: "0",
  ease: "power3.inOut",
  delay: 4,
});

gsap.to(".block-left", 2, {
  left: "-50%",
  ease: "power3.inOut",
  delay: 4,
});

gsap.to(".block-right", 2, {
  right: "-50%",
  ease: "power3.inOut",
  delay: 4,
});

// Isometric
let text = document.getElementById("text");
let shadow = "";
for (let i = 0; i < 30; i++) {
  shadow += (shadow ? "," : "") + -i * 1 + "px " + i * 1 + "px 0 #d9d9d9";
}
text.style.textShadow = shadow;

// VanilaTilt
VanillaTilt.init(document.querySelectorAll(".card"), {
  max: 25,
  speed: 400,
  glare: true,
  "max-glare": 1,
});

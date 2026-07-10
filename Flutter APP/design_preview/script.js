const screenButtons = document.querySelectorAll("[data-target]");
const phoneCards = document.querySelectorAll(".phone-card");
const tabButtons = document.querySelectorAll(".tab-btn");

function setActiveScreen(target) {
  phoneCards.forEach((card) => {
    card.classList.toggle("active", card.dataset.screen === target);
  });

  tabButtons.forEach((button) => {
    button.classList.toggle("active", button.dataset.target === target);
  });
}

screenButtons.forEach((button) => {
  button.addEventListener("click", (event) => {
    const target = event.currentTarget.dataset.target;
    if (target) {
      setActiveScreen(target);
    }
  });
});

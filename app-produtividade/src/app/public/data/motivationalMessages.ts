export const motivationalMessages = [
  "Great job! Keep pushing your limits! 💪",
  "You're making progress every day! 🌟",
  "Small steps lead to big achievements! 🎯",
  "Success is built one task at a time! 🏆",
  "You're unstoppable! Keep going! 🚀",
  "Excellence is a habit, and you're building it! ⭐",
  "Your dedication is inspiring! 🌈",
  "Every completion is a victory! 🎉"
];

export const getRandomMessage = () => {
  const randomIndex = Math.floor(Math.random() * motivationalMessages.length);
  return motivationalMessages[randomIndex];
};
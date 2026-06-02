import { type Antagonist, Category } from '../base';

const Operative: Antagonist = {
  key: 'operatives',
  name: 'Operative',
  description: [
    'A highly trained stealth operative deployed to infiltrate and disrupt from within.',
    'Move quietly, complete your objectives, and vanish before anyone knows you were there.',
  ],
  category: Category.Latejoin,
};

export default Operative;

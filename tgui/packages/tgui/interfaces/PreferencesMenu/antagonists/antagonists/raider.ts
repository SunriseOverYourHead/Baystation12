import { type Antagonist, Category } from '../base';

const Raider: Antagonist = {
  key: 'raider',
  name: 'Raider',
  description: [
    'A space pirate drawn to the Torch by opportunity.',
    'Board the vessel, take what you need by force or guile, and make your escape.',
  ],
  category: Category.Latejoin,
};

export default Raider;

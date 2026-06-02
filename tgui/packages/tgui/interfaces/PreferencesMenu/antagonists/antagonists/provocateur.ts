import { type Antagonist, Category } from '../base';

const Provocateur: Antagonist = {
  key: 'provocateur',
  name: 'Deuteragonist',
  description: [
    'A minor antagonist driven by self-interest above all else.',
    "Survive the round at any cost — betray allies, cut deals with enemies, keep your gun handy.",
  ],
  category: Category.Roundstart,
};

export default Provocateur;

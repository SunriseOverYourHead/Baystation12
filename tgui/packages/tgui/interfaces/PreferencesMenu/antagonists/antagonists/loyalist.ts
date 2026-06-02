import { type Antagonist, Category } from '../base';

const Loyalist: Antagonist = {
  key: 'loyalist',
  name: 'Loyalist',
  description: [
    'A corporate agent loyal to NanoTrasen\'s true interests.',
    'Undermine dissidents and ensure the station remains under NanoTrasen control.',
  ],
  category: Category.Roundstart,
};

export default Loyalist;

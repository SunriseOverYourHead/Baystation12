import { type Antagonist, Category } from '../base';

const VoxRaider: Antagonist = {
  key: 'voxraider',
  dmId: 'vox raider',
  name: 'Vox Raider',
  description: [
    'A Vox raider from a distant arkship, driven by instinct and profit.',
    'Board the Torch, grab what you need, and escape with your crew before security can respond.',
  ],
  category: Category.Latejoin,
};

export default VoxRaider;

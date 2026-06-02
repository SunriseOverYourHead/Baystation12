import { type Antagonist, Category } from '../base';

const FoundationAgent: Antagonist = {
  key: 'foundationagent',
  dmId: 'foundation agent',
  name: 'Foundation Agent',
  description: [
    'A covert operative deployed by a shadowy organization with interests aboard the Torch.',
    "Blend in with the crew, gather intelligence, and advance the Foundation's agenda from within.",
  ],
  category: Category.Latejoin,
};

export default FoundationAgent;

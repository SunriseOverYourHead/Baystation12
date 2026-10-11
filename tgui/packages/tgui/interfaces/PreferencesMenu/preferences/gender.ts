export enum Gender {
  Male = 'male',
  Female = 'female',
  Other = 'plural',
  Other2 = 'neuter',
}

export const GENDERS = {
  [Gender.Male]: {
    icon: 'mars',
    text: 'Male',
  },

  [Gender.Female]: {
    icon: 'venus',
    text: 'Female',
  },

  [Gender.Other]: {
    icon: 'transgender',
    text: 'Trans',
  },

  [Gender.Other2]: {
    icon: 'neuter',
    text: 'Other',
  },
};

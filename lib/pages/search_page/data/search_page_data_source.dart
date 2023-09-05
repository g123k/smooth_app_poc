// TODO Replace this with real data

final List<String> fakeSearchHistory = [];
const List<String> fakeSearchSuggestions = [
  'Nutella',
  'Cristaline',
  'Pâtes à la bolognaise',
];

void addToHistory(String search) {
  if (fakeSearchHistory.contains(search)) {
    fakeSearchHistory.remove(search);
  }

  fakeSearchHistory.insert(0, search);
}

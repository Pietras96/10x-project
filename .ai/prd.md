# Dokument wymagań produktu (PRD) - 10x-Cards

## 1. Przegląd produktu

10x-Cards to aplikacja webowa typu MVP (Minimum Viable Product), której celem jest wspomaganie procesu tworzenia materiałów do nauki języka angielskiego. System wykorzystuje sztuczną inteligencję do automatycznego generowania spersonalizowanych fiszek na podstawie dowolnego tekstu dostarczonego przez użytkownika. Aplikacja łączy w sobie efektywność algorytmu powtórek SuperMemo-2 (SM-2) z łatwością tworzenia treści, eliminując barierę czasową, która często zniechęca do systematycznej nauki. Rozwiązanie jest dedykowane polskim użytkownikom uczącym się języka angielskiego.

## 2. Problem użytkownika

Tradycyjne metody tworzenia fiszek są czasochłonne i wymagają dużego nakładu pracy manualnej. Użytkownik, chcąc nauczyć się słówek z artykułu czy książki, musi ręcznie wyszukiwać definicje, tłumaczenia, konteksty użycia oraz przykłady, a następnie wpisywać je do aplikacji. Ten proces przygotowawczy zajmuje często więcej czasu niż sama nauka, co prowadzi do spadku motywacji i rezygnacji z systematycznych powtórek. Ponadto, samodzielnie tworzone fiszki mogą zawierać błędy merytoryczne lub być niedopasowane do rzeczywistego poziomu zaawansowania uczącego się.

## 3. Wymagania funkcjonalne

### 3.1. System AI i Generowanie Treści
- API przyjmujące tekst wejściowy o długości od 1000 do 10000 znaków.
- Analiza tekstu i ekstrakcja słownictwa dopasowanego do zadeklarowanego poziomu użytkownika.
- Automatyczne tworzenie struktury fiszki:
  - Przód: Słowo/Fraza lub zdanie z kontekstem (opcjonalnie z luką).
  - Tył: Tłumaczenie na język polski, definicja w języku angielskim, przykładowe zdanie w języku angielskim, lista innych popularnych znaczeń.
- Ograniczenie wizualne treści do maksymalnie 2 linijek na zdanie.
- Walidacja języka (blokada generowania dla tekstów w języku innym niż angielski).
- Pomijanie duplikatów fiszek już istniejących w bazie użytkownika.
- Limit 50 generacji dziennie na użytkownika (zmniejszany tylko po poprawnym wygenerowaniu).

### 3.2. Zarządzanie Fiszkami (Drafty i Baza)
- Tryb Recenzji (Draft): Tymczasowa sesja przeglądarki do weryfikacji wygenerowanych fiszek karta po karcie.
- Akcje w trybie recenzji: Akceptuj (zapisz do bazy), Edytuj (popraw przed zapisem), Odrzuć (usuń).
- Ostrzeżenie przed utratą niezatwierdzonych draftów przy próbie nawigacji wewnątrz aplikacji.
- Moduł CRUD: Ręczne tworzenie, edycja i usuwanie fiszek z bazy w ramach listy "Moje fiszki".
- Przeglądanie bazy fiszek: Lista z paginacją i wyszukiwarką.

### 3.3. Moduł Nauki
- Implementacja algorytmu SuperMemo-2 (SM-2) do zarządzania interwałami powtórek.
- Globalny przycisk `Powtórki na dziś` uruchamiający sesję nauki.
- Interfejs nauki umożliwiający ocenę stopnia zapamiętania (zgodnie z SM-2).
- Blokada edycji fiszki w trakcie trwania sesji nauki.
- Resetowanie interwału powtórek w przypadku edycji merytorycznej fiszki poza sesją nauki.

### 3.4. Profilowanie i Konto Użytkownika
- Autentykacja za pomocą adresu email i hasła.
- Ustawienie poziomu zaawansowania językowego (np. A1-C2), wpływające na dobór słownictwa przez AI.
- Dashboard użytkownika prezentujący liczniki: `Liczba fiszek`, `Streak` (dni nauki z rzędu).
- Możliwość trwałego usunięcia konta wraz ze wszystkimi danymi.

## 4. Granice produktu

### W zakresie (In Scope)
- Aplikacja webowa dostępna przez przeglądarkę (RWD).
- Para językowa: Angielski -> Polski.
- Wklejanie tekstu jako jedyna metoda wprowadzania danych dla AI.
- Algorytm powtórek SuperMemo-2.
- System autentykacji email/hasło.

### Poza zakresem (Out of Scope)
- Natywne aplikacje mobilne (iOS/Android).
- Importowanie fiszek z plików (PDF, DOCX, TXT, CSV).
- Własny, autorski algorytm powtórek (korzystamy tylko ze sprawdzonego SM-2).
- Współdzielenie fiszek między użytkownikami lub publiczne zestawy.
- Integracje z zewnętrznymi aplikacjami (np. Kindle, Pocket).
- Obsługa innych języków niż angielski.

## 5. Historyjki użytkowników

### Uwierzytelnianie i Konto

ID: US-001
Tytuł: Logowanie do systemu
Opis: Jako zarejestrowany użytkownik, chcę zalogować się na swoje konto, aby uzyskać dostęp do moich fiszek.
Kryteria akceptacji:
- Użytkownik może zalogować się podając poprawny email i hasło.
- System wyświetla komunikat błędu przy niepoprawnych danych.
- po poprawnym zalogowaniu następuje przekierowanie do widoku generowania fiszek
- Sesja użytkownika jest utrzymywana po odświeżeniu strony.
- dane logowania są przechowywane w bezpieczny sposób
- nie mam dostępu do fiszek innych użytkowników ani możliwości współdzielenia

ID: US-002
Tytuł: Usuwanie konta
Opis: Jako użytkownik, chcę mieć możliwość usunięcia swojego konta, aby trwale wymazać swoje dane z systemu.
Kryteria akceptacji:
- Opcja usuwania konta jest dostępna w ustawieniach profilu.
- System wymaga dodatkowego potwierdzenia decyzji.
- Usunięcie konta usuwa wszystkie fiszki i historię nauki użytkownika z bazy danych.

### Profilowanie

ID: US-003
Tytuł: Ustawienie poziomu językowego
Opis: Jako użytkownik, chcę określić swój poziom znajomości angielskiego, aby AI generowało fiszki odpowiednie do moich umiejętności.
Kryteria akceptacji:
- Użytkownik wybiera poziom z listy (np. A1, A2, B1, B2, C1, C2).
- Wybór jest zapisywany w profilu użytkownika.
- Zmiana poziomu wpływa na przyszłe generacje fiszek, nie zmieniając już istniejących.

### Generowanie Fiszek (AI)

ID: US-005
Tytuł: Generowanie fiszek z tekstu
Opis: Jako użytkownik, chcę wkleić tekst artykułu, aby system automatycznie utworzył propozycje fiszek z trudnymi słowami.
Kryteria akceptacji:
- System posiada pole tekstowe przyjmujące od 1000 do 10000 znaków.
- System blokuje próbę wysłania tekstu w języku innym niż angielski.
- System generuje listę propozycji fiszek zgodnie ze zdefiniowaną strukturą.
- System filtruje słowa, które użytkownik ma już w swojej bazie (duplikaty).

ID: US-006
Tytuł: Limit dzienny generacji
Opis: Jako użytkownik, chcę widzieć ile generacji mogę jeszcze wykonać danego dnia, aby kontrolować zużycie limitu.
Kryteria akceptacji:
- Licznik dostępnych generacji (max 50) jest widoczny w interfejsie.
- Licznik zmniejsza się o 1 tylko po udanym wygenerowaniu zestawu fiszek.
- Po wyczerpaniu limitu przycisk generowania staje się nieaktywny do następnego dnia.

### Zarządzanie Draftami

ID: US-007
Tytuł: Recenzja wygenerowanych fiszek
Opis: Jako użytkownik, chcę przeglądać wygenerowane fiszki jedna po drugiej, aby zdecydować o ich dodaniu do nauki.
Kryteria akceptacji:
- Interfejs wyświetla wygenerowane fiszki w trybie wizarda (krok po kroku).
- Użytkownik widzi przód i tył proponowanej fiszki.
- Użytkownik ma dostęp do akcji: Akceptuj, Edytuj, Odrzuć.

ID: US-008
Tytuł: Edycja draftu
Opis: Jako użytkownik, chcę mieć możliwość poprawienia treści wygenerowanej fiszki przed jej zaakceptowaniem, aby była idealnie dopasowana do moich potrzeb.
Kryteria akceptacji:
- Wybranie opcji `Edytuj` pozwala zmienić każde pole tekstowe fiszki.
- Po zapisaniu zmian fiszka jest automatycznie akceptowana i dodawana do bazy.

ID: US-009
Tytuł: Ostrzeżenie o utracie draftów
Opis: Jako użytkownik, chcę otrzymać ostrzeżenie przy próbie wyjścia z widoku recenzji, aby nie stracić niezatwierdzonych fiszek.
Kryteria akceptacji:
- Próba przejścia do innej podstrony aplikacji podczas recenzji wywołuje modal z ostrzeżeniem.
- Użytkownik może potwierdzić wyjście (utrata danych) lub anulować i wrócić do recenzji.

### Nauka i Powtórki

ID: US-010
Tytuł: Codzienna sesja nauki
Opis: Jako użytkownik, chcę kliknąć jeden przycisk, aby rozpocząć powtarzanie materiału zaplanowanego na dziś.
Kryteria akceptacji:
- Przycisk `Powtórki na dziś` jest widoczny na dashboardzie.
- Kliknięcie uruchamia tryb nauki tylko dla fiszek, których termin powtórki przypada na dziś lub wcześniej.
- Jeśli brak fiszek do powtórki, system wyświetla stosowny komunikat.


### Dashboard i Zarządzanie Ręczne

ID: US-012
Tytuł: Śledzenie postępów (Streak)
Opis: Jako użytkownik, chcę widzieć, ile dni z rzędu się uczę, aby budować nawyk systematyczności.
Kryteria akceptacji:
- Licznik `Streak` na dashboardzie pokazuje aktualną serię dni.
- Seria rośnie, jeśli użytkownik wykonał chociaż jedną powtórkę danego dnia.
- Brak aktywności przez cały dzień resetuje licznik do zera.

ID: US-013
Tytuł: Ręczne dodawanie fiszki
Opis: Jako użytkownik, chcę samodzielnie stworzyć fiszkę od podstaw, aby dodać słowa spoza generatora AI.
Kryteria akceptacji:
- Formularz pozwala uzupełnić wszystkie pola struktury fiszki.
- Nowa fiszka jest od razu zapisywana w bazie i dostępna do nauki.

ID: US-014
Tytuł: Wyszukiwanie i lista fiszek
Opis: Jako użytkownik, chcę przeszukać moją bazę fiszek, aby znaleźć konkretne słowo lub zwrot.
Kryteria akceptacji:
- Lista fiszek posiada pole wyszukiwania.
- Wyszukiwanie działa po frazie angielskiej i polskiej.
- Wyniki są filtrowane w czasie rzeczywistym lub po zatwierdzeniu.

## 6. Metryki sukcesu

- **Adopcja AI (Creation Rate):** Minimum 75% wszystkich fiszek w systemie zostało utworzonych przy użyciu generatora AI (a nie ręcznie).
- **Jakość AI (Acceptance Rate):** Minimum 75% fiszek zaproponowanych przez AI w trybie draftu jest akceptowanych przez użytkownika (bez odrzucenia).


from __future__ import annotations


def book(
    title: str,
    author: str,
    description: str | None = None,
    *,
    language: str = "en",
    featured: bool = False,
):
    if description is None:
        if language == "ar":
            description = (
                f"\u0631\u0648\u0627\u064a\u0629 \u0645\u0634\u0647\u0648\u0631\u0629 \u0645\u0646 \u062a\u0623\u0644\u064a\u0641 {author} "
                "\u0623\u064f\u0636\u064a\u0641\u062a \u0625\u0644\u0649 \u0627\u0644\u0645\u0643\u062a\u0628\u0629 "
                "\u0627\u0644\u0639\u0631\u0628\u064a\u0629 \u0627\u0644\u0645\u062e\u062a\u0627\u0631\u0629 \u0641\u064a "
                "\u0627\u0644\u062a\u0637\u0628\u064a\u0642."
            )
        else:
            description = (
                f"A well-known book by {author} selected for the app's curated library "
                "of modern and classic favorites."
            )

    return {
        "title": title,
        "author": author,
        "description": description,
        "language": language,
        "featured": featured,
    }


ENGLISH_BOOKS = [
    book(
        "Alice's Adventures in Wonderland",
        "Lewis Carroll",
        "A playful classic of riddles, reversals, and impossible logic that turns curiosity into adventure.",
        featured=True,
    ),
    book(
        "The Hobbit",
        "J.R.R. Tolkien",
        "Bilbo Baggins leaves comfort behind for a dragon-haunted quest that reshapes Middle-earth.",
        featured=True,
    ),
    book(
        "The Fellowship of the Ring",
        "J.R.R. Tolkien",
        "The journey begins as the Ring leaves the Shire and a fellowship forms around an impossible burden.",
        featured=True,
    ),
    book("The Two Towers", "J.R.R. Tolkien"),
    book("The Return of the King", "J.R.R. Tolkien"),
    book(
        "Harry Potter and the Sorcerer's Stone",
        "J.K. Rowling",
        "The first Hogwarts year opens a magical world while grounding it in friendship, mystery, and wonder.",
        featured=True,
    ),
    book("Harry Potter and the Chamber of Secrets", "J.K. Rowling"),
    book("Harry Potter and the Prisoner of Azkaban", "J.K. Rowling"),
    book("Harry Potter and the Goblet of Fire", "J.K. Rowling"),
    book("Harry Potter and the Order of the Phoenix", "J.K. Rowling"),
    book("Harry Potter and the Half-Blood Prince", "J.K. Rowling"),
    book("Harry Potter and the Deathly Hallows", "J.K. Rowling"),
    book(
        "Pride and Prejudice",
        "Jane Austen",
        "Austen's sharpest social comedy turns first impressions into one of literature's great romances.",
        featured=True,
    ),
    book("Sense and Sensibility", "Jane Austen"),
    book("Emma", "Jane Austen"),
    book(
        "Jane Eyre",
        "Charlotte Bronte",
        "A fiercely self-possessed heroine carries this gothic coming-of-age novel with moral intensity.",
        featured=True,
    ),
    book("Wuthering Heights", "Emily Bronte"),
    book("Villette", "Charlotte Bronte"),
    book("Great Expectations", "Charles Dickens"),
    book("Oliver Twist", "Charles Dickens"),
    book("A Tale of Two Cities", "Charles Dickens"),
    book("David Copperfield", "Charles Dickens"),
    book("Bleak House", "Charles Dickens"),
    book("Little Women", "Louisa May Alcott"),
    book("Anne of Green Gables", "L.M. Montgomery"),
    book("The Secret Garden", "Frances Hodgson Burnett"),
    book("Peter Pan", "J.M. Barrie"),
    book("Treasure Island", "Robert Louis Stevenson"),
    book("Kidnapped", "Robert Louis Stevenson"),
    book("The Adventures of Tom Sawyer", "Mark Twain"),
    book("Adventures of Huckleberry Finn", "Mark Twain"),
    book("The Prince and the Pauper", "Mark Twain"),
    book("The Call of the Wild", "Jack London"),
    book("White Fang", "Jack London"),
    book("The Jungle Book", "Rudyard Kipling"),
    book("The Wind in the Willows", "Kenneth Grahame"),
    book("The Wonderful Wizard of Oz", "L. Frank Baum"),
    book("Charlotte's Web", "E.B. White"),
    book("Watership Down", "Richard Adams"),
    book(
        "The Lion, the Witch and the Wardrobe",
        "C.S. Lewis",
        "A wardrobe door opens into a mythic winter where courage and mercy matter as much as magic.",
        featured=True,
    ),
    book("Prince Caspian", "C.S. Lewis"),
    book("The Voyage of the Dawn Treader", "C.S. Lewis"),
    book("Fahrenheit 451", "Ray Bradbury"),
    book(
        "1984",
        "George Orwell",
        "A defining dystopia about surveillance, language, and the political destruction of reality.",
        featured=True,
    ),
    book("Animal Farm", "George Orwell"),
    book("Brave New World", "Aldous Huxley"),
    book("Lord of the Flies", "William Golding"),
    book(
        "To Kill a Mockingbird",
        "Harper Lee",
        "A humane, enduring novel about childhood, justice, and moral courage under pressure.",
        featured=True,
    ),
    book("The Great Gatsby", "F. Scott Fitzgerald"),
    book("Of Mice and Men", "John Steinbeck"),
    book("The Grapes of Wrath", "John Steinbeck"),
    book("East of Eden", "John Steinbeck"),
    book("The Old Man and the Sea", "Ernest Hemingway"),
    book("The Sun Also Rises", "Ernest Hemingway"),
    book("For Whom the Bell Tolls", "Ernest Hemingway"),
    book("The Catcher in the Rye", "J.D. Salinger"),
    book("Slaughterhouse-Five", "Kurt Vonnegut"),
    book("Catch-22", "Joseph Heller"),
    book("Beloved", "Toni Morrison"),
    book("Invisible Man", "Ralph Ellison"),
    book("Their Eyes Were Watching God", "Zora Neale Hurston"),
    book("The Color Purple", "Alice Walker"),
    book("The Bell Jar", "Sylvia Plath"),
    book("Rebecca", "Daphne du Maurier"),
    book("Mrs Dalloway", "Virginia Woolf"),
    book("To the Lighthouse", "Virginia Woolf"),
    book("A Passage to India", "E.M. Forster"),
    book("Heart of Darkness", "Joseph Conrad"),
    book("The Picture of Dorian Gray", "Oscar Wilde"),
    book("Dracula", "Bram Stoker"),
    book("Frankenstein", "Mary Shelley"),
    book("The Strange Case of Dr Jekyll and Mr Hyde", "Robert Louis Stevenson"),
    book("The Time Machine", "H.G. Wells"),
    book("The War of the Worlds", "H.G. Wells"),
    book("The Adventures of Sherlock Holmes", "Arthur Conan Doyle"),
    book("The Hound of the Baskervilles", "Arthur Conan Doyle"),
    book("Murder on the Orient Express", "Agatha Christie"),
    book("And Then There Were None", "Agatha Christie"),
    book("The Shining", "Stephen King"),
    book("It", "Stephen King"),
    book("Misery", "Stephen King"),
    book(
        "Dune",
        "Frank Herbert",
        "A monumental science-fiction saga where prophecy, ecology, and empire collide in the desert.",
        featured=True,
    ),
    book("The Handmaid's Tale", "Margaret Atwood"),
    book("The Road", "Cormac McCarthy"),
    book("Life of Pi", "Yann Martel"),
    book("The Kite Runner", "Khaled Hosseini"),
    book("The Book Thief", "Markus Zusak"),
    book("The Hunger Games", "Suzanne Collins"),
    book("Catching Fire", "Suzanne Collins"),
    book("Mockingjay", "Suzanne Collins"),
    book("The Fault in Our Stars", "John Green"),
    book("The Martian", "Andy Weir"),
    book("Gone Girl", "Gillian Flynn"),
    book("The Girl on the Train", "Paula Hawkins"),
    book("The Da Vinci Code", "Dan Brown"),
    book("The Secret History", "Donna Tartt"),
    book("The Goldfinch", "Donna Tartt"),
    book("The Night Circus", "Erin Morgenstern"),
    book("The Remains of the Day", "Kazuo Ishiguro"),
    book("Atonement", "Ian McEwan"),
]

ARABIC_BOOKS = [
    book(
        "\u0623\u0645\u0648\u0627\u062c \u0623\u0643\u0645\u0627",
        "\u0639\u0645\u0631\u0648 \u0639\u0628\u062f \u0627\u0644\u062d\u0645\u064a\u062f",
        "\u0627\u0644\u062c\u0632\u0621 \u0627\u0644\u0623\u062e\u064a\u0631 \u0645\u0646 \u0633\u0644\u0633\u0644\u0629 "
        "\u0642\u0648\u0627\u0639\u062f \u062c\u0627\u0631\u062a\u064a\u0646\u060c \u062d\u064a\u062b \u062a\u062a\u0648\u0627\u0635\u0644 "
        "\u0623\u062d\u062f\u0627\u062b \u0622\u062f\u0645 \u0648\u063a\u0641\u0631\u0627\u0646 \u0641\u064a \u0639\u0627\u0644\u0645 "
        "\u0645\u0644\u064a\u0621 \u0628\u0627\u0644\u0635\u0631\u0627\u0639 \u0648\u0627\u0644\u0623\u0633\u0631\u0627\u0631.",
        language="ar",
        featured=True,
    ),
    book(
        "\u062b\u0644\u0627\u062b\u064a\u0629 \u063a\u0631\u0646\u0627\u0637\u0629",
        "\u0631\u0636\u0648\u0649 \u0639\u0627\u0634\u0648\u0631",
        "\u0645\u0644\u062d\u0645\u0629 \u062a\u0627\u0631\u064a\u062e\u064a\u0629 \u062a\u062a\u0628\u0639 \u062d\u064a\u0627\u0629 "
        "\u0639\u0627\u0626\u0644\u0629 \u0623\u0646\u062f\u0644\u0633\u064a\u0629 \u0628\u0639\u062f \u0633\u0642\u0648\u0637 \u063a\u0631\u0646\u0627\u0637\u0629.",
        language="ar",
        featured=True,
    ),
    book(
        "\u0645\u0648\u0633\u0645 \u0627\u0644\u0647\u062c\u0631\u0629 \u0625\u0644\u0649 \u0627\u0644\u0634\u0645\u0627\u0644",
        "\u0627\u0644\u0637\u064a\u0628 \u0635\u0627\u0644\u062d",
        "\u0631\u0648\u0627\u064a\u0629 \u0639\u0631\u0628\u064a\u0629 \u0645\u0624\u062b\u0631\u0629 \u062a\u0641\u0643\u0643 "
        "\u0627\u0644\u0647\u0648\u064a\u0629 \u0648\u0627\u0644\u0633\u0644\u0637\u0629 \u0648\u0645\u064a\u0631\u0627\u062b "
        "\u0627\u0644\u0627\u0633\u062a\u0639\u0645\u0627\u0631.",
        language="ar",
        featured=True,
    ),
    book(
        "\u0631\u062c\u0627\u0644 \u0641\u064a \u0627\u0644\u0634\u0645\u0633",
        "\u063a\u0633\u0627\u0646 \u0643\u0646\u0641\u0627\u0646\u064a",
        language="ar",
    ),
    book(
        "\u0639\u0645\u0627\u0631\u0629 \u064a\u0639\u0642\u0648\u0628\u064a\u0627\u0646",
        "\u0639\u0644\u0627\u0621 \u0627\u0644\u0623\u0633\u0648\u0627\u0646\u064a",
        language="ar",
    ),
    book("\u0639\u0632\u0627\u0632\u064a\u0644", "\u064a\u0648\u0633\u0641 \u0632\u064a\u062f\u0627\u0646", language="ar"),
    book("\u0632\u0642\u0627\u0642 \u0627\u0644\u0645\u062f\u0642", "\u0646\u062c\u064a\u0628 \u0645\u062d\u0641\u0648\u0638", language="ar"),
    book("\u0623\u0648\u0644\u0627\u062f \u062d\u0627\u0631\u062a\u0646\u0627", "\u0646\u062c\u064a\u0628 \u0645\u062d\u0641\u0648\u0638", language="ar"),
    book("\u0630\u0627\u0643\u0631\u0629 \u0627\u0644\u062c\u0633\u062f", "\u0623\u062d\u0644\u0627\u0645 \u0645\u0633\u062a\u063a\u0627\u0646\u0645\u064a", language="ar"),
    book("\u064a\u0648\u062a\u0648\u0628\u064a\u0627", "\u0623\u062d\u0645\u062f \u062e\u0627\u0644\u062f \u062a\u0648\u0641\u064a\u0642", language="ar"),
]

assert len(ENGLISH_BOOKS) == 100
assert len(ARABIC_BOOKS) == 10

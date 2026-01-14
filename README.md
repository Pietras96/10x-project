# 10x-Cards

> An AI-powered English learning application utilizing the SuperMemo-2 algorithm for effective spaced repetition.

## 2. Project Description

**10x-Cards** is a Minimum Viable Product (MVP) web application designed to streamline the process of creating language learning materials. By leveraging LLM, the system automatically generates personalized flashcards from any English text provided by the user.

Key features include:
- **AI-Powered Generation**: Extracts vocabulary, definitions, and context from texts (1,000 - 10,000 characters).
- **Smart Learning**: Implements the SuperMemo-2 (SM-2) algorithm to optimize review intervals.
- **Review System**: A dedicated "Draft" mode to verify, edit, or reject AI-suggested cards.
- **Progress Tracking**: User dashboard with streaks and learning statistics.
- **Focus**: Dedicated to Polish speakers learning English.

## 3. Tech Stack

### Frontend
- **Framework**: [Astro 5](https://astro.build/) - High-performance static and server-rendered architecture.
- **UI Library**: [React 19](https://react.dev/) - For interactive components.
- **Styling**: [Tailwind CSS 4](https://tailwindcss.com/) & [Shadcn/ui](https://ui.shadcn.com/).
- **Language**: [TypeScript 5](https://www.typescriptlang.org/).

### Backend & Services
- **Backend-as-a-Service**: [Supabase](https://supabase.com/) (PostgreSQL, Authentication).
- **AI Integration**: [Openrouter.ai](https://openrouter.ai/) (Access to OpenAI, Anthropic, etc.).

### DevOps
- **CI/CD**: GitHub Actions.
- **Hosting**: DigitalOcean (Dockerized).

## 4. Getting Started Locally

Follow these instructions to get the project up and running on your local machine.

### Prerequisites
- **Node.js**: Version `22.14.0` (as specified in `.nvmrc`).
- **Package Manager**: npm, pnpm, or yarn.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Pietras96/10x-project.git
   cd 10x-cards
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory. You will need to configure the following services:
   - **Supabase**: URL and Anon Key.
   - **Openrouter**: API Key for AI generation.

   Example `.env` structure:
   ```env
   PUBLIC_SUPABASE_URL=your_supabase_url
   PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   OPENROUTER_API_KEY=your_openrouter_key
   ```

4. **Run the development server**
   ```bash
   npm run dev
   ```
   The application will be available at `http://localhost:4321`.

## 5. Available Scripts

In the project directory, you can run:

| Script | Description |
| :--- | :--- |
| `npm run dev` | Starts the local development server with hot reloading. |
| `npm run build` | Builds the production-ready site to the `dist/` directory. |
| `npm run preview` | Previews the production build locally. |
| `npm run lint` | Runs ESLint to check for code quality issues. |
| `npm run lint:fix` | Automatically fixes fixable linting errors. |
| `npm run format` | Formats code using Prettier. |

## 6. Project Scope

### In Scope
- Web application accessible via browser (Responsive Web Design).
- Language pair: English -> Polish.
- Input method: Text pasting for AI analysis.
- Algorithms: SuperMemo-2 (SM-2) for spaced repetition.
- Authentication: Email/Password via Supabase.

### Out of Scope
- Native mobile applications (iOS/Android).
- File imports (PDF, DOCX, etc.).
- Public flashcard sets or sharing features.
- Support for languages other than English.

## 7. Project Status

🚧 **Status**: MVP / Active Development

The project is currently in the MVP phase, focusing on core functionalities like user authentication, AI flashcard generation, and the basic learning loop.

## 8. License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

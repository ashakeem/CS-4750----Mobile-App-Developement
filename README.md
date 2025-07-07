# Gift Match

Find the perfect gift in 5 questions. AI-powered suggestions, swipe to like/save, synced with Supabase.

## Quick Setup
1. Clone repo & install deps:
   ```bash
   git clone <repo-url>
   cd flutter_application_1
   flutter pub get
   ```
2. Create `.env` in root:
   ```env
   SUPABASE_URL=your_url
   SUPABASE_ANON_KEY=your_key
   OPENAI_API_KEY=your_key
   ```
3. Start Supabase (local):
   ```bash
   supabase start
   supabase db reset
   ```
4. Run app:
   ```bash
   flutter run
   ```

## Demo Script (2 min)
- Sign in with email (magic link)
- Complete 5-step wizard
- Swipe through AI gift ideas
- Save a gift, go to Saved tab
- Share a saved gift
- Recap: fast, AI-powered gift finding

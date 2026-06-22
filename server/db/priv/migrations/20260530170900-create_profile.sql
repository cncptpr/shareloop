--- migration:up

CREATE TABLE profiles (
    -- id SERIAL PRIMARY KEY,
    -- user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,

    name TEXT NOT NULL,
    bio TEXT,

    rating DECIMAL(3,2),
    
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_profile_user_id ON profiles(id);

--- migration:down

DROP TABLE profiles;

--- migration:end


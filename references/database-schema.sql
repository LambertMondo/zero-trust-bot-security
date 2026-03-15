CREATE TABLE users (
    id                BIGSERIAL PRIMARY KEY,
    platform_user_id  BIGINT UNIQUE NOT NULL,
    username          TEXT,
    role              TEXT DEFAULT 'user',
    memory            TEXT,
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE groups (
    id                  BIGSERIAL PRIMARY KEY,
    platform_channel_id BIGINT UNIQUE NOT NULL,
    title               TEXT,
    owner_platform_id   BIGINT,
    trust_config        JSONB DEFAULT '{}'::jsonb,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    is_active           BOOLEAN DEFAULT TRUE
);

CREATE TABLE bans (
    id                BIGSERIAL PRIMARY KEY,
    platform_user_id  BIGINT NOT NULL,
    reason            TEXT,
    is_active         BOOLEAN DEFAULT TRUE,
    expires_at        TIMESTAMPTZ
);

CREATE TABLE quotas (
    platform_user_id    BIGINT NOT NULL,
    platform_channel_id BIGINT NOT NULL,
    date                DATE NOT NULL DEFAULT CURRENT_DATE,
    usage_count         INT DEFAULT 0,
    PRIMARY KEY (platform_user_id, platform_channel_id, date)
);

CREATE OR REPLACE FUNCTION consume_quota(
    p_user_id BIGINT,
    p_channel_id BIGINT
) RETURNS INT AS $$
    INSERT INTO quotas (platform_user_id, platform_channel_id, date, usage_count)
    VALUES (p_user_id, p_channel_id, CURRENT_DATE, 1)
    ON CONFLICT (platform_user_id, platform_channel_id, date)
    DO UPDATE SET usage_count = quotas.usage_count + 1
    RETURNING usage_count;
$$ LANGUAGE sql;

CREATE TABLE audit_log (
    id                BIGSERIAL PRIMARY KEY,
    type              TEXT NOT NULL,
    role              TEXT,
    user_id           BIGINT,
    channel_id        BIGINT,
    pattern_matched   TEXT,
    request_snippet   TEXT,
    response_snippet  TEXT,
    severity          TEXT,
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE channel_contexts (
    channel_id        BIGINT PRIMARY KEY,
    type              TEXT,
    role              TEXT,
    identity_md       TEXT,
    bootstrap_md      TEXT,
    memory_md         TEXT
);

CREATE TABLE memory (
    id                BIGSERIAL PRIMARY KEY,
    user_id           BIGINT REFERENCES users(id),
    group_id          BIGINT REFERENCES groups(id),
    content           TEXT NOT NULL,
    type              TEXT DEFAULT 'fact',
    access_tier       TEXT,
    created_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE registration_requests (
    id                BIGSERIAL PRIMARY KEY,
    group_id          TEXT NOT NULL,
    requester_id      TEXT NOT NULL,
    status            TEXT DEFAULT 'pending',
    reviewed_by       TEXT,
    created_at        TIMESTAMPTZ DEFAULT NOW(),
    reviewed_at       TIMESTAMPTZ
);

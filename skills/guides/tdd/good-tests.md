# Good and bad tests

Short examples for the rules in [SKILL.md](SKILL.md), in Python (Django and pytest) and JavaScript (Vitest or Jest). Each pair tests the same behaviour, so the difference is only in how.

## Test through the public path

A good test checks what a user or caller sees. A bad one checks how the code gets there, so it breaks on a harmless refactor.

```python
# GOOD: goes through the URL, as a user would, and checks what they see.
def test_closed_month_rejects_booking(client, closed_month):
    response = client.post("/bookings/", {"date": "2026-03-14"})
    assert response.status_code == 400
    assert "March is closed" in response.content.decode()

# BAD: reaches into a private helper and asserts it was called.
def test_booking_checks_month(mocker):
    check = mocker.patch("bookings.views._month_is_open", return_value=False)
    create_booking(date(2026, 3, 14))
    check.assert_called_once()
```

```javascript
// GOOD: uses the public functions to save, then to read back.
test("a created user can be fetched", async () => {
  const user = await createUser({ name: "Alice" });
  const fetched = await getUser(user.id);
  expect(fetched.name).toBe("Alice");
});

// BAD: checks the side channel (the database) instead of the public path.
test("createUser inserts a row", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});
```

## Take expected values from outside the code

A tautological test works out the answer the same way the code does, so it can never catch a mistake in that working.

```python
# GOOD: the expected total is a literal you can check by hand.
def test_order_total_adds_line_items():
    assert order_total([{"price": 10}, {"price": 5}]) == 15

# BAD: recomputes the answer the way order_total does.
def test_order_total_adds_line_items():
    items = [{"price": 10}, {"price": 5}]
    assert order_total(items) == sum(i["price"] for i in items)
```

```javascript
// GOOD
expect(formatPrice(1999)).toBe("$19.99");

// BAD: the expected value repeats the implementation's formula.
expect(formatPrice(1999)).toBe(`$${(1999 / 100).toFixed(2)}`);
```

## Mock only what you don't control

Mock external services, time and randomness. Run your own code, and a test database, for real.

```python
# GOOD: the email service is external, so it's mocked; the time is fixed so
# the test gives the same result every day. Django's test database is real.
def test_signup_sends_welcome_email(client, mocker, freezer):
    freezer.move_to("2026-10-15")
    send = mocker.patch("accounts.emails.send_email")
    client.post("/signup/", {"email": "a@example.com"})
    send.assert_called_once()
    assert User.objects.get(email="a@example.com").joined == date(2026, 10, 15)

# BAD: mocks the app's own model, so the test passes even if saving is broken.
def test_signup_creates_user(client, mocker):
    create = mocker.patch("accounts.views.User.objects.create")
    client.post("/signup/", {"email": "a@example.com"})
    create.assert_called_once()
```

```javascript
// GOOD: pass the external client in, so a test can hand over a fake one.
async function chargeOrder(order, paymentClient) {
  return paymentClient.charge(order.total);
}

test("charges the order total", async () => {
  const paymentClient = { charge: vi.fn().mockResolvedValue({ ok: true }) };
  await chargeOrder({ total: 1500 }, paymentClient);
  expect(paymentClient.charge).toHaveBeenCalledWith(1500);
});

// BAD: the client is built inside, so the only way to test it is to mock a
// module import, or to send a real charge.
async function chargeOrder(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

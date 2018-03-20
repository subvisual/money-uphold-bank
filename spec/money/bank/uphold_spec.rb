require "spec_helper"
require "money"
require "money/bank/uphold"

RSpec.describe Money::Bank::Uphold do
  subject { Money::Bank::Uphold.new }

  def disable_rates!
    allow(subject).to receive(:exchange_rates).
      and_return([])
  end

  context "exchange" do
    context "without rates" do
      it "is able to exchange money to its own currency" do
        disable_rates!
        money = Money.new(0, :USD)

        exchanged_money = subject.exchange_with(money, :USD)

        expect(money).to eq exchanged_money
      end

      it "is unable to exchange money between two different currencies" do
        disable_rates!
        money = Money.new(1, :USD)

        expect do
          subject.exchange_with(money, :EUR)
        end.to raise_error Money::Bank::UnknownRate
      end
    end

    context "with rates" do
      it "is able to exchange money between know currencies" do
        money = Money.new(100, :USD)

        exchanged_money = subject.exchange_with(money, :AUD)

        expect(exchanged_money).to eq Money.new(130, :AUD)
      end

      it "is able to exchange money back to USD" do
        money = Money.new(100, :USD)

        exchanged_money = subject.exchange_with(money, :AUD)
        original_money = subject.exchange_with(exchanged_money, :USD)

        expect(original_money).to eq money
      end

      it "raises an error for unknown currencies" do
        money = Money.new(100, :USD)

        expect do
          subject.exchange_with(money, :XXX)
        end.to raise_error Money::Currency::UnknownCurrency
      end
    end
  end

  context "update rates" do
    it "should override existing rates" do
      subject.add_rate(:EUR, :BTC, 300)

      subject.update_rates

      expect(subject.get_rate(:EUR, :BTC)).not_to eq 300
    end
  end

  context "expire rates" do
    context "with up-to-date rates" do
      it "does not update the rates" do
        allow(subject).to receive(:rates_expired?).and_return(false)

        expect(subject).not_to receive(:update_rates)

        subject.get_rate(:USD, :EUR)
      end
    end

    context "with outdated-to-date rates" do
      it "does not update the rates" do
        allow(subject).to receive(:rates_expired?).and_return(true)

        expect(subject).to receive(:update_rates)

        subject.get_rate(:USD, :EUR)
      end
    end
  end
end

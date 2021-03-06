#10497: wait_until_tor_is_working
@product @fragile
Feature: The Tor enforcement is effective
  As a Tails user
  I want all direct Internet connections I do by mistake or applications do by misconfiguration or buggy leaks to be blocked
  And as a Tails developer
  I want to ensure that the automated test suite detects firewall leaks reliably

  Scenario: Tails' Tor binary is configured to use the expected Tor authorities
    Given I have started Tails from DVD and logged in and the network is connected
    Then the Tor binary is configured to use the expected Tor authorities

  Scenario: The firewall configuration is very restrictive
    Given I have started Tails from DVD and logged in and the network is connected
    Then the firewall's policy is to drop all IPv4 traffic
    And the firewall is configured to only allow the clearnet and debian-tor users to connect directly to the Internet over IPv4
    And the firewall's NAT rules only redirect traffic for Tor's TransPort and DNSPort
    And the firewall is configured to block all external IPv6 traffic

  @fragile
  Scenario: Anti test: Detecting IPv4 TCP leaks from the Unsafe Browser with the firewall leak detector
    Given I have started Tails from DVD and logged in and the network is connected
    And I capture all network traffic
    When I successfully start the Unsafe Browser
    And I open the address "https://check.torproject.org" in the Unsafe Browser
    And I see "UnsafeBrowserTorCheckFail.png" after at most 60 seconds
    Then the firewall leak detector has detected IPv4 TCP leaks

  Scenario: Anti test: Detecting IPv4 TCP leaks of TCP DNS lookups with the firewall leak detector
    Given I have started Tails from DVD and logged in and the network is connected
    And I capture all network traffic
    And I disable Tails' firewall
    When I do a TCP DNS lookup of "torproject.org"
    Then the firewall leak detector has detected IPv4 TCP leaks

  Scenario: Anti test: Detecting IPv4 non-TCP leaks (UDP) of UDP DNS lookups with the firewall leak detector
    Given I have started Tails from DVD and logged in and the network is connected
    And I capture all network traffic
    And I disable Tails' firewall
    When I do a UDP DNS lookup of "torproject.org"
    Then the firewall leak detector has detected IPv4 non-TCP leaks

  Scenario: Anti test: Detecting IPv4 non-TCP (ICMP) leaks of ping with the firewall leak detector
    Given I have started Tails from DVD and logged in and the network is connected
    And I capture all network traffic
    And I disable Tails' firewall
    When I send some ICMP pings
    Then the firewall leak detector has detected IPv4 non-TCP leaks

  @check_tor_leaks
  Scenario: The Tor enforcement is effective at blocking untorified TCP connection attempts
    Given I have started Tails from DVD and logged in and the network is connected
    When I open an untorified TCP connections to 1.2.3.4 on port 42 that is expected to fail
    Then the untorified connection fails
    And the untorified connection is logged as dropped by the firewall

  @check_tor_leaks
  Scenario: The Tor enforcement is effective at blocking untorified UDP connection attempts
    Given I have started Tails from DVD and logged in and the network is connected
    When I open an untorified UDP connections to 1.2.3.4 on port 42 that is expected to fail
    Then the untorified connection fails
    And the untorified connection is logged as dropped by the firewall

  @check_tor_leaks @fragile
  Scenario: The Tor enforcement is effective at blocking untorified ICMP connection attempts
    Given I have started Tails from DVD and logged in and the network is connected
    When I open an untorified ICMP connections to 1.2.3.4 that is expected to fail
    Then the untorified connection fails
    And the untorified connection is logged as dropped by the firewall

  Scenario: The system DNS is always set up to use Tor's DNSPort
    Given I have started Tails from DVD without network and logged in
    And the system DNS is using the local DNS resolver
    And the network is plugged
    And Tor is ready
    Then the system DNS is still using the local DNS resolver

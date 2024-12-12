/* eslint-disable react/no-danger */
// 80 characters is not big enough for my yiff yiff
/* eslint-disable max-len */
import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  Fragment,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

// Welcome to the FoodPrinter.js file. This is where your food printing adventure begins.
// Layout will have four main sections:
// 0. HEADER: The top section with the title and a button for helpmepls
// 1. WORKLIST: The top section with the work list of things being printed
// 2. MENUPANE: The left section with the menu of items to print
// 3. INFO: The upper right section with the info about the selected item
// 4. OUTPUT: The lower right section with selections for output
// 5. FOOTER: The bottom section with the print button and other options

// Constants
const WorkOrderHeight = "50px";
const WorkOrderWidth = "130px";
const HeaderBoxStyle = {
  "color": "#FFFFFF",
  "font-size": "16px",
  "font-weight": "bold",
};

// The skeleton of the FoodPrinter!
export const FoodPrinter = (props, context) => {
  const { data } = useBackend(context);

  const [
    HelpActive,
    setHelpActive,
  ] = useLocalState(context, 'HelpActive', false);

  return (
    <Window
      width={800}
      height={600}>
      <Window.Content
        style={{
          "background": "linear-gradient(180deg, #2F4F4F, #1F3A3A)",
        }}>
        {HelpActive && (
          <HelpSection />
        ) || (
          <Stack fill vertical>
            <Stack.Item>
              <TopSection />
            </Stack.Item>
            <Stack.Item grow shrink>
              <BodySection />
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};

// The top section of the FoodPrinter
// Contains the header and worklist
const TopSection = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    WorkOrders = [],
  } = data;

  const CancelEverything = () => {
    return (
      <Button
        icon="times"
        onClick={() => act('CancelAllOrders')} />
    );
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Header />
      </Stack.Item>
      <Stack.Item shrink>
        <Section fill>
          <Box style={HeaderBoxStyle}>
            Currently working on:
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item mt={0}>
        <Section fill>
          {WorkOrders.length > 0
            ? (
              <Stack fill vertical>
                <Stack.Item>
                  <WorkOrder
                    item={WorkOrders[0]} />
                </Stack.Item>
                {WorkOrders.length > 1
                  ? (
                    <Stack.Item>
                      {CancelEverything()} {WorkOrders.length - 1} more in queue! =3
                    </Stack.Item>
                  )
                  : null}
              </Stack>
            )
            : (
              <Box>
                Standing by for orders! =3
              </Box>
            )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// The individual work order in the Worklist
// Contains the name of the item being printed, a progress bar, and a cancel button
// Also who its for!
const WorkOrder = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    Beacons = [],
  } = data;
  const {
    item,
  } = props;
  const {
    Name,
    Description,
    Amount,
    OutputTag,
    TimeLeft,
    TimeLeftPercent,
    MyTag,
  } = item;

  const WhoFor = Beacons.find(beacon => beacon.BeaconID === OutputTag)?.DisplayName
    || "Right here!";

  const CancelButton = () => {
    return (
      <Button
        icon="times"
        onClick={() => act('CancelOrder', {
          'FoodKey': MyTag,
        })} />
    );
  };

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <Box
            style={HeaderBoxStyle}>
            {CancelButton()} {`${Amount}x ${Name}`}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box>
            {`For: ${WhoFor}`}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <ProgressBar
            value={TimeLeftPercent}
            minValue={0}
            maxValue={100}>
            <Box textAlign="center">
              {`${TimeLeft}`}
            </Box>
          </ProgressBar>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

// The header of the FoodPrinter
const Header = (props, context) => {
  const { data } = useBackend(context);
  const {
    CoolTip,
    Tagline,
  } = data;

  const [
    HelpActive,
    setHelpActive,
  ] = useLocalState(context, 'HelpActive', false);

  return (
    <Section fill>
      <Stack fill>
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  <Box style={HeaderBoxStyle}>
                    {`GekkerTec FoodFox 2000 - ${Tagline}`}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="question"
                    content="Help"
                    onClick={() => setHelpActive(!HelpActive)} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Box
                width="80vw"
                fontSize="10px">
                <Table>
                  <Table.Row>
                    <Table.Cell>
                      {CoolTip}
                    </Table.Cell>
                  </Table.Row>
                </Table> {/* OKAY SO PUTTING IT IN A TABLE MAKES IT WRAP, FUKC TGUI */}
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};


// The body section of the FoodPrinter
// Contains the menu pane, info pane, and output pane
// OR is the help menu if the help button is clicked
const BodySection = (props, context) => {
  const { data } = useBackend(context);
  const [
    HelpActive,
    setHelpActive,
  ] = useLocalState(context, 'HelpActive', false);

  // GROSS GRIDPANE
  return (
    <Stack fill>
      <Stack.Item basis="33%">
        <MenuPane />
      </Stack.Item>
      <Stack.Item basis="33%">
        <InfoPane />
      </Stack.Item>
      <Stack.Item basis="33%">
        <Stack fill vertical>
          <Stack.Item grow>
            <OutputPane />
          </Stack.Item>
          <Stack.Item>
            <FooterButt />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

// The Menu pane of the FoodPrinter
// Another list holder! Also perfroms search flitering
const MenuPane = (props, context) => {
  const { data } = useBackend(context);
  const {
    EntriesPerPage = 50,
    FoodMenuList = [[]], // array of arrays of food objects
    FullFoodMenu = [], // array of food objects (warning: xbox hueg)
  } = data;

  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  // Name
  // Description
  // Categories
  // NutritionalFacts
  // PrintTime
  // FoodKey

  const [
    searchPage,
    setSearchPage,
  ] = useLocalState(context, 'searchPage', 0);
  const CoolSetSearchText = (stext) => {
    setSearchText(stext);
    setSearchPage(0);
  };

  const testSearch = createSearch(searchText, item => {
    return item.Name;
  });

  // if no search text, show the appropriate page of the full menu
  // if there is search text, show the appropriate page of the filtered search results
  const OurFoodList = searchText.length > 0
    ? FullFoodMenu
      .filter(testSearch)
      .slice(searchPage * EntriesPerPage, (searchPage + 1) * EntriesPerPage)
    : FoodMenuList[searchPage];

  const TotalPages = searchText.length > 0
    ? Math.ceil(OurFoodList.length / EntriesPerPage)
    : FoodMenuList.length;

  const BackPageButton = () => {
    if (searchPage <= 0 || searchText.length > 0) {
      return (
        <Button
          icon="arrow-left"
          disabled />
      );
    } else {
      return (
        <Button
          icon="arrow-left"
          onClick={() => setSearchPage(searchPage - 1)} />
      );
    }
  };

  const NextPageButton = () => {
    if (searchPage >= TotalPages - 1 || searchText.length > 0) {
      return (
        <Button
          icon="arrow-right"
          disabled />
      );
    } else {
      return (
        <Button
          icon="arrow-right"
          onClick={() => setSearchPage(searchPage + 1)} />
      );
    }
  };

  const Paginumi = () => {
    if (OurFoodList.length <= EntriesPerPage)
    { return (" - "); }
    return (
      ` ${searchPage + 1} / ${TotalPages} `
    );
  };

  // "Showing results 51-100 out of 1000"
  // "Showing results 1-21 out of 21"
  const ResultsNum = () => {
    if (searchText.length <= 0)
    { return (
      `Showing results ${searchPage * EntriesPerPage + 1}-${Math.min((searchPage + 1) * EntriesPerPage, OurFoodList.length)} out of ${FullFoodMenu.length}`
    ); }
    if (OurFoodList.length <= EntriesPerPage)
    { return (
      `Showing results 1-${OurFoodList.length} out of ${OurFoodList.length}`
    ); }
    return (
      `Showing results ${searchPage * EntriesPerPage + 1}-${Math.min((searchPage + 1) * EntriesPerPage, OurFoodList.length)} out of ${OurFoodList.length}`
    );
  };

  const SubHeaderStyle = {
    "color": "#FFFFFF",
    "font-size": "12px",
    "font-weight": "bold",
    "text-align": "center",
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section fill mb={0}>
          <Stack fill>
            <Stack.Item grow>
              <Box style={HeaderBoxStyle}>
                Food Menu
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Input
                icon="search"
                placeholder="Search"
                value={searchText}
                onInput={(e, value) => CoolSetSearchText(value)} />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow shrink mt={0}>
        <Section fill scrollable>
          <Table>
            {OurFoodList.map((item, index) => (
              <Table.Row
                key={index}>
                <Table.Cell>
                  <MenuItem
                    item={item} />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item shrink mt={0}>
        <Section fill>
          <Stack fill>
            <Stack.Item grow>
              <Box
                style={SubHeaderStyle}
                textAlign="center">
                {ResultsNum()}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Stack fill>
                <Stack.Item>
                  <BackPageButton />
                </Stack.Item>
                <Stack.Item grow>
                  <Box
                    style={SubHeaderStyle}
                    textAlign="center">
                    {Paginumi()}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <NextPageButton />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// The individual menu item in the MenuPane
// Just a button! It sets the
const MenuItem = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    item,
  } = props;
  const {
    Name,
    Description,
    Categories,
    NutritionalFacts,
    PrintTime,
    FoodKey,
  } = item;
  const [
    selectedItem,
    setSelectedItem,
  ] = useLocalState(context, 'selectedItem', '');

  const TruncName = Name.length > 20
    ? Name.substring(0, 20) + "..."
    : Name;

  return (
    <Button
      mb={1}
      width="100%"
      content={Name}
      selected={selectedItem === FoodKey}
      onClick={() => setSelectedItem(FoodKey)} />
  );
};

// The Info pane of the FoodPrinter
// Contains the info about the selected item
const InfoPane = (props, context) => {
  const { data } = useBackend(context);
  const {
    FullFoodMenu = [],
  } = data;

  const [
    selectedItem,
    setSelectedItem,
  ] = useLocalState(context, 'selectedItem', '');

  if (!selectedItem) {
    return (
      <Stack fill vertical>
        <Stack.Item>
          <Section fill>
            <Box
              style={HeaderBoxStyle}>
              Info
            </Box>
          </Section>
        </Stack.Item>
        <Stack.Item grow mt={0}>
          <Section fill>
            No item selected!
          </Section>
        </Stack.Item>
      </Stack>
    );
  }

  const TrueItem = FullFoodMenu.find(item => item.FoodKey === selectedItem);

  const {
    Name = "Some Food",
    Description = "Some kind of food?",
    NutritionalFacts = {},
    PrintTime = 10,
    FoodKey = "somefood",
  } = TrueItem;

  // nutfacts has a format of:
  // {
  //   "Calories": 100,
  //   "Sugar": 10,
  //   "Protein": 10,
  //   "Some Kind of Reagent": 10,
  //   "Some Other Kind of Reagent": 10,
  // }
  // the first three are always present, the rest are optional
  const NutThree = {
    "Calories": NutritionalFacts["Calories"],
    "Sugars": NutritionalFacts["Sugars"],
    "Vitamins": NutritionalFacts["Vitamins"],
  };
  const NutRest = Object.keys(NutritionalFacts)
    .filter(key => !Object.keys(NutThree).includes(key))
    .map(key => ({
      [key]: NutritionalFacts[key],
    }));

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section fill mb={0}>
          <Stack fill>
            <Stack.Item grow>
              <Box style={HeaderBoxStyle}>
                {Name}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Section
                width="50px">
                <Icon
                  name="hourglass-half" />
                {PrintTime}s
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item mt={0}>
        <Section fill>
          {Description}
        </Section>
      </Stack.Item>
      <Stack.Item grow shrink mt={0}>
        <Section fill scrollable>
          <Stack fill>
            <Stack.Item>
              <LabeledList>
                {Object.entries(NutThree).map(([key, value]) => (
                  <LabeledList.Item
                    key={key}
                    label={key}>
                    {value}
                  </LabeledList.Item>
                ))}
                <LabeledList.Divider />
                {NutRest.map((item, index) => (
                  <LabeledList.Item
                    key={index}
                    label={Object.keys(item)[0]}>
                    {Object.values(item)[0]}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// The Output pane of the FoodPrinter
// Contains where you can make the item go to
const OutputPane = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    // Beacons = [
    //   {
    //     "DisplayName": "Kitchen",
    //     "BeaconID": "bnriobnin-wiener",
    //   }, ...
    // ],
    Beacons = [],
    SelectedBeacon = '',
  } = data;

  const SendHere = !SelectedBeacon;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section fill mb={0}>
          <Stack fill>
            <Stack.Item grow>
              <Box
                style={HeaderBoxStyle}>
                Output Where?
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                selected={SendHere}
                content="Just here"
                onClick={() => act('SetTargetBeacon', {
                  'BeaconKey': '',
                })} />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow shrink mt={0}>
        <Section fill scrollable>
          <Stack fill vertical>
            {Beacons.map((item, index) => (
              <Stack.Item
                key={index}>
                <Button
                  width="100%"
                  content={item.DisplayName}
                  selected={SelectedBeacon === item.BeaconID}
                  onClick={() => act('SetTargetBeacon', {
                    'BeaconKey': item.BeaconID,
                  })} />
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item mt={0}>
        <Section fill>
          <Button
            icon="plus"
            content="Make a new beacon!"
            onClick={() => act('NewBeacon')} />
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// The Footer of the FoodPrinter
// Contains the print button and other options
const FooterButt = (props, context) => {
  const { data, act } = useBackend(context);
  const [
    selectedItem,
    setSelectedItem,
  ] = useLocalState(context, 'selectedItem', '');
  const [
    SelectedBeacon,
    setSelectedBeacon,
  ] = useLocalState(context, 'SelectedBeacon', '');

  if (!selectedItem) {
    return (
      <NoticeBox>
        No item selected!
      </NoticeBox>
    );
  }

  return (
    <Section fill>
      <Stack fill>
        <Stack.Item grow>
          Print!
        </Stack.Item>
        <Stack.Item>
          <Button
            content="1"
            onClick={() => act('PrintFood', {
              'FoodKey': selectedItem,
              // 'OutputTag': SelectedBeacon,
              'Amount': 1,
            })} />
        </Stack.Item>
        <Stack.Item>
          <Button
            content="5"
            onClick={() => act('PrintFood', {
              'FoodKey': selectedItem,
              // 'OutputTag': SelectedBeacon,
              'Amount': 5,
            })} />
        </Stack.Item>
        <Stack.Item>
          <Button.Input
            content={"More?"}
            maxValue={30}
            onCommit={(e, value) => act('PrintFood', {
              'FoodKey': selectedItem,
              // 'OutputTag': SelectedBeacon,
              'Amount': value,
            })} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

// The Help section of the FoodPrinter
// Contains the help menu
const HelpSection = (props, context) => {
  const { data } = useBackend(context);
  const {
    FullFoodMenu = [],
  } = data;

  const [
    HelpActive,
    setHelpActive,
  ] = useLocalState(context, 'HelpActive', false);

  return (
    <Section
      fill
      title="How to FoodFox!"
      fontSize="11px"
      buttons={(
        <Button
          icon="question"
          onClick={() => setHelpActive(false)} />
      )}>
      <Stack fill vertical>
        <Stack.Item>
          {"Thank you for choosing the GekkerTec FoodFox 2000 for your intergalactic food printing needs!"}
          <br />
          {"Here's a quick guide on how to use your FoodFox:"}
        </Stack.Item>
        <Stack.Item>
          <Divider />
        </Stack.Item>
        <Stack.Item>
          <Stack fill>
            <Stack.Item basis="25%">
              <Section
                fill
                title="Step 1: Select a Meal">
                <Box>
                  <p>{"This panel on the left lists every meal available in the GekkerTec CuliMax database. "}
                    {`There are ${`[${FullFoodMenu.length}]`} meals to choose from, all listed in alphabetical order. `}
                    {"As you can see, the list is quite long! So, we here at GekkerTec have divided this list into pages for easy leafing. "}
                    {"You can also search through the entire database by typing in the search bar at the top of the panel. "}
                    {"Once you've found something you (or your customers) like, click on it to select it."}
                    <p />
                    {"Step 1 complete!"}
                  </p>
                  <hr />
                  {"<ADDENDUM> If you see any items with 'strange' names, it probably makes a lot more sense wherever the recipe came from. "}
                  {"I didn't make the recipes, I just made a thing that scraped them off our PortalNet. "}
                  <br />
                  {"- Dan Kelly <ADDENDUM END>"}
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item basis="25%">
              <Section
                fill
                title="Step 2: Review the Meal">
                <Box>
                  <p>{"Once you've selected a meal, this panel in the middle will display the nutritional facts and a brief description. "}
                    {"Here you can see the name of the meal, a brief description of it, and its nutritional facts. "}
                    {"There's also a timer that shows how long it will take to source the meal. "}
                    <p />
                    {"Step 2 complete!"}
                  </p>
                  <hr />
                  {"<ADDENDUM> The system's definition of 'food' is unbelievably broad, so don't be surprised if you see some... oddities. "}
                  {"While everything is technically edible, not everything is necessarily a good idea to eat. You have been warned. "}
                  {"If you *have* eaten something that you wish you hadn't, please contact my sister Sam, she's not a doctor, but she is a good listener. "}
                  <br />
                  {"- Dan Kelly <ADDENDUM END>"}
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item basis="25%">
              <Section
                fill
                title="Step 3: Pick a Destination">
                <Box>
                  <p>{"Once you've selected a meal and reviewed it, this panel on the right will allow you to select where the meal will be sent. "}
                    {"By default, the meal will be sent to the nearest table/counter to the FoodFox 2000. "}
                    {"However, if there are any DinnerDelivery 'Food Beacons' registered in the system, you can opt to send the meal there instead. "}
                    {"To do this, simply click on the name of the beacon you wish to send the meal to, before you set it to start! "}
                    <p />
                    {"Step 3 complete!"}
                  </p>
                  <hr />
                  {"<ADDENDUM> The beacons don't seem to have a max range that I could find, so as long as you have one, you can send food to it. "}
                  {"And I know what you're thinking, yes it still works if you put it in there, and yes it does what you'd expect. =3 "}
                  <br />{"- Dan Kelly <ADDENDUM END>"}
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item basis="25%">
              <Section
                fill
                title="Step 4: Generate the Meal">
                <Box>
                  <p>{"Once you've selected a meal, reviewed it, and picked a destination, you're ready to generate the meal! "}
                    {"Simply click on the number of meals you wish to generate, and the FoodFox 2000 will begin sourcing the meal. "}
                    {"Once the meal is ready, it will be sent to the destination you selected. "}
                    {"And that's it! You've successfully used the GekkerTec FoodFox 2000! "}
                    <br />
                    {"Enjoy your meal!"}
                  </p>
                  <hr />
                  {"<ADDENDUM> If you have any questions, comments, or concerns, please don't hesitate to contact me. "}
                  {"I'm always happy to help!"}
                  <br />{"- Dan Kelly <ADDENDUM END>"}
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
